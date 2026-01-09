class Location::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @locations = find_locations
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(Ipos::LocationSerializer.new(@locations, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @locations.total_count,
      total_pages: @locations.total_pages
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Location)
    allowed_includes = [:location]
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
    @fields = filter_authorize_fields(fields: result.fields, record_class: Ipos::Location)
  end

  def find_locations
    locations = Ipos::Location.all.includes(@query_included)
                              .page(@page)
                              .per(@limit)
    locations = locations.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%")) if @search_text.present?
    @filters.each do |filter|
      locations = filter.add_filter_to_query(locations)
    end
    if @sort.present?
      locations.order(@sort)
    else
      locations.order(id: :asc)
    end
  end
end
