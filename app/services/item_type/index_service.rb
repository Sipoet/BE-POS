class ItemType::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @item_types = find_item_types
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::ItemTypeSerializer.new(@item_types,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @item_types.total_pages,
      total_rows: @item_types.total_count,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::ItemType)
    allowed_fields = [:item_type]
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

  def find_item_types
    item_types = Ipos::ItemType.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      item_types = item_types.where(['jenis ilike ? OR ketjenis ilike ? ']+ Array.new(2,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      item_types = item_types.where(filter.to_query)
    end
    if @sort.present?
      item_types = item_types.order(@sort)
    else
      item_types = item_types.order(jenis: :asc)
    end
    item_types
  end

end
