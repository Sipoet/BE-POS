class PurchaseReturn::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @purchase_returns = find_purchase_returns
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::PurchaseReturnSerializer.new(@purchase_returns, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @purchase_returns.total_count,
      total_pages: @purchase_returns.total_pages
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::PurchaseReturn)
    allowed_includes = %i[purchase_return supplier]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @query_included = result.query_included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::PurchaseReturn)
  end

  def find_purchase_returns
    purchase_returns = Ipos::PurchaseReturn.all.includes(@query_included)
                                           .page(@page)
                                           .per(@limit)
    if @search_text.present?
      purchase_returns = purchase_returns.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      purchase_returns = purchase_returns.where(filter.to_query)
    end
    if @sort.present?
      purchase_returns.order(@sort)
    else
      purchase_returns.order(id: :asc)
    end
  end
end
