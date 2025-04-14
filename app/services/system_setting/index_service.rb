class SystemSetting::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @settings = find_settings
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(SystemSettingSerializer.new(@settings,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @settings.total_count,
       total_pages: @settings.total_pages,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Setting)
    allowed_fields = [:setting]
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

  def find_settings
    settings = Setting.all.includes(@query_included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      settings = settings.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      settings = filter.add_filter_to_query(settings)
    end
    if @sort.present?
      settings = settings.order(@sort)
    else
      settings = settings.order(id: :asc)
    end
    settings
  end

end
