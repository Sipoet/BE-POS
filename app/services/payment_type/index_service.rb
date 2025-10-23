class PaymentType::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @payment_types = find_payment_types
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(PaymentTypeSerializer.new(@payment_types, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @payment_types.total_count,
      total_pages: @payment_types.total_pages
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(PaymentType)
    allowed_includes = [:payment_type]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: PaymentType)
  end

  def find_payment_types
    payment_types = PaymentType.all.includes(@included)
                               .page(@page)
                               .per(@limit)
    payment_types = payment_types.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%")) if @search_text.present?
    @filters.each do |filter|
      payment_types = payment_types.where(filter.to_query)
    end
    if @sort.present?
      payment_types.order(@sort)
    else
      payment_types.order(id: :asc)
    end
  end
end
