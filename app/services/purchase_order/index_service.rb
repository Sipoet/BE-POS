class PurchaseOrder::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @purchase_orders = find_purchase_orders
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::PurchaseOrderSerializer.new(@purchase_orders, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @purchase_orders.total_count,
      total_pages: @purchase_orders.total_pages
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::PurchaseOrder)
    allowed_includes = %i[purchase_order purchase_order_items supplier]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @query_included = result.query_included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::PurchaseOrder)
  end

  def find_purchase_orders
    purchase_orders = Ipos::PurchaseOrder.all.includes(@query_included)
                                         .page(@page)
                                         .per(@limit)
    if @search_text.present?
      purchase_orders = purchase_orders.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      purchase_orders = purchase_orders.where(filter.to_query)
    end
    if @sort.present?
      purchase_orders.order(@sort)
    else
      purchase_orders.order(id: :asc)
    end
  end
end
