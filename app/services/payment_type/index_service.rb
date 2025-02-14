class PaymentType::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @payment_types = find_payment_types
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(PaymentTypeSerializer.new(@payment_types,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @payment_types.total_count,
       total_pages: @payment_types.total_pages,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(PaymentType)
    allowed_fields = [:payment_type]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = result.fields
  end

  def find_payment_types
    payment_types = PaymentType.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      payment_types = payment_types.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      payment_types = payment_types.where(filter.to_query)
    end
    if @sort.present?
      payment_types = payment_types.order(@sort)
    else
      payment_types = payment_types.order(id: :asc)
    end
    payment_types
  end

end
