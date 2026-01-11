class Item::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @items = find_items
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    Rails.logger.debug "=====options: #{options}"
    render_json(Ipos::ItemSerializer.new(@items, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @items.total_pages,
      total_rows: @items.total_count
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Ipos::Item)
    allowed_includes = %i[item supplier brand item_type]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Item)
  end

  def find_items
    items = Ipos::Item.all.includes(@included)
                      .page(@page)
                      .per(@limit)
    if @search_text.present?
      items = items.where(['namaitem ilike ? OR kodeitem ilike ? '] + Array.new(2, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      items = items.where(filter.to_query)
    end
    if @sort.present?
      items.order(@sort)
    else
      items.order(kodeitem: :asc)
    end
  end
end
