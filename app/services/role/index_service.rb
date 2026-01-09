class Role::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @roles = find_roles
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(RoleSerializer.new(@roles, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @roles.total_pages,
      total_rows: @roles.total_count
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Role)
    allowed_includes = [:role]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: Role)
  end

  def find_roles
    roles = Role.all.includes(@included)
                .page(@page)
                .per(@limit)
    roles = roles.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%")) if @search_text.present?
    @filters.each do |filter|
      roles = roles.where(filter.to_query)
    end
    if @sort.present?
      roles.order(@sort)
    else
      roles.order(name: :asc)
    end
  end
end
