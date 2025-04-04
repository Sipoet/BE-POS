class Location::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @locations = find_locations
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::LocationSerializer.new(@locations,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @locations.total_count,
       total_pages: @locations.total_pages,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Location)
    allowed_fields = [:location]
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

  def find_locations
    locations = Ipos::Location.all.includes(@query_included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      locations = locations.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      locations = filter.add_filter_to_query(locations)
    end
    if @sort.present?
      locations = locations.order(@sort)
    else
      locations = locations.order(id: :asc)
    end
    locations
  end

end
