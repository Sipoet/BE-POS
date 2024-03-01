class Item::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @items = find_items
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(ItemSerializer.new(@items,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @items.total_pages,
    }
  end

  def extract_params
    allowed_columns = Ipos::Item::TABLE_HEADER.map(&:name)
    allowed_fields = [:item,:supplier,:brand, :item_type]
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

  def find_items
    items = Ipos::Item.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      items = items.where(['namaitem ilike ? OR kodeitem ilike ? ']+ Array.new(2,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      items = items.where(filter.to_query)
    end
    if @sort.present?
      items = items.order(@sort)
    else
      items = items.order(kodeitem: :asc)
    end
    items
  end

end
