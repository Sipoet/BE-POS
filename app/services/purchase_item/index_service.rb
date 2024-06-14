class PurchaseItem::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @purchase_items = find_purchase_items
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::PurchaseItemSerializer.new(@purchase_items,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @purchase_items.total_count,
      total_pages: @purchase_items.total_pages,
    }
  end

  def extract_params
    allowed_columns = Ipos::PurchaseItem::TABLE_HEADER.map(&:name)
    allowed_fields = [:purchase_item, :item]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = result.fields
  end

  def find_purchase_items
    purchase_items = Ipos::PurchaseItem.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      purchase_items = purchase_items.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      purchase_items = purchase_items.where(filter.to_query)
    end
    if @sort.present?
      purchase_items = purchase_items.order(@sort)
    else
      purchase_items = purchase_items.order(kodeitem: :asc)
    end
    purchase_items
  end

end
