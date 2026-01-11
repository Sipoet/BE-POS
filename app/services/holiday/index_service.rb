class Holiday::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @holidays = find_holidays
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(HolidaySerializer.new(@holidays, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @holidays.total_count,
      total_pages: @holidays.total_pages
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Holiday)
    allowed_includes = [:holiday]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @query_included = result.query_included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Holiday)
  end

  def find_holidays
    holidays = Holiday.all.includes(@query_included)
                      .page(@page)
                      .per(@limit)
    holidays = holidays.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%")) if @search_text.present?
    @filters.each do |filter|
      holidays = holidays.where(filter.to_query)
    end
    if @sort.present?
      holidays.order(@sort)
    else
      holidays.order(id: :asc)
    end
  end
end
