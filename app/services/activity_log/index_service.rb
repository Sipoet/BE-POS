class ActivityLog::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @activity_logs = find_activity_logs
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(ActivityLogSerializer.new(@activity_logs,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @versions.total_pages,
      total_rows: @versions.total_count,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(ActivityLog)
    allowed_fields = [:activity_log,:user]
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

  def find_activity_logs
    @versions = Version.all.includes(@included)
      .page(@page)
      .per(@limit)
    @filters.each do |filter|
      @versions = @versions.where(filter.to_query)
    end
    if @sort.present?
      @versions = @versions.order(@sort)
    else
      @versions = @versions.order(created_at: :desc)
    end
    @versions.map do |version|
      ActivityLog.from_version(version)
    end
  end

end
