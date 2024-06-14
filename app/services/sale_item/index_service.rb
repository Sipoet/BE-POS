class SaleItem::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @sale_items = find_sale_items
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::SaleItemSerializer.new(@sale_items,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @sale_items.count,
       total_pages: @sale_items.total_pages,
    }
  end

  def extract_params
    allowed_columns = Ipos::SaleItem::TABLE_HEADER.map(&:name)
    allowed_fields = [:sale_item]
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

  def find_sale_items
    sale_items = Ipos::SaleItem.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      sale_items = sale_items.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      sale_items = sale_items.where(filter.to_query)
    end
    if @sort.present?
      sale_items = sale_items.order(@sort)
    else
      sale_items = sale_items.order(id: :asc)
    end
    sale_items
  end

end
