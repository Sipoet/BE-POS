class Holiday::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @holidays = find_holidays
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(HolidaySerializer.new(@holidays,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @holidays.count,
       total_pages: @holidays.total_pages,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Holiday)
    allowed_fields = [:holiday]
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

  def find_holidays
    holidays = Holiday.all.includes(@query_included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      holidays = holidays.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      holidays = holidays.where(filter.to_query)
    end
    if @sort.present?
      holidays = holidays.order(@sort)
    else
      holidays = holidays.order(id: :asc)
    end
    holidays
  end

end
