class PaymentMethod::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @payment_methods = find_payment_methods
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(PaymentMethodSerializer.new(@payment_methods, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @payment_methods.total_pages,
      total_rows: @payment_methods.total_count
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(PaymentMethod)
    allowed_fields = %i[payment_method provider]
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

  def find_payment_methods
    payment_methods = PaymentMethod.all.includes(@included)
                                   .page(@page)
                                   .per(@limit)
    if @search_text.present?
      payment_methods = payment_methods.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      payment_methods = payment_methods.where(filter.to_query)
    end
    if @sort.present?
      payment_methods.order(@sort)
    else
      payment_methods.order(id: :asc)
    end
  end
end
