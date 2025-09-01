class PurchaseReturn::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @purchase_returns = find_purchase_returns
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::PurchaseReturnSerializer.new(@purchase_returns,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @purchase_returns.total_count,
       total_pages: @purchase_returns.total_pages,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::PurchaseReturn)
    allowed_fields = [:purchase_return,:supplier]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @query_included = result.query_included
    @filters = result.filters
    @fields = result.fields
  end

  def find_purchase_returns
    purchase_returns = Ipos::PurchaseReturn.all.includes(@query_included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      purchase_returns = purchase_returns.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      purchase_returns = purchase_returns.where(filter.to_query)
    end
    if @sort.present?
      purchase_returns = purchase_returns.order(@sort)
    else
      purchase_returns = purchase_returns.order(id: :asc)
    end
    purchase_returns
  end

end
