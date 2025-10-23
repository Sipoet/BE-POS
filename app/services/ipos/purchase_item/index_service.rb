class Ipos::PurchaseItem::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @purchase_items = find_purchase_items
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::PurchaseItemSerializer.new(@purchase_items, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @purchase_items.total_count,
      total_pages: @purchase_items.total_pages
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::PurchaseItem)
    allowed_includes = %i[purchase_item item purchase]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::PurchaseItem)
  end

  def find_purchase_items
    purchase_items = Ipos::PurchaseItem.all.includes(@included)
                                       .page(@page)
                                       .per(@limit)
    if @search_text.present?
      search_query_arr = [
        'tbl_item.kodeitem ilike ?',
        'tbl_item.namaitem ilike ?',
        'tbl_imhd.notransaksi ilike ?',
        'tbl_item.supplier1 ilike ?',
        'tbl_item.jenis ilike ?',
        'tbl_item.merek ilike ?'
      ]
      purchase_items = purchase_items.where([search_query_arr.join(' OR ')] + Array.new(search_query_arr.length,
                                                                                        "%#{@search_text}%"))
                                     .left_outer_joins(:item, :purchase)

    end
    @filters.each do |filter|
      purchase_items = purchase_items.where(filter.to_query)
    end
    if @sort.present?
      purchase_items.order(@sort)
    else
      purchase_items.order(kodeitem: :asc)
    end
  end
end
