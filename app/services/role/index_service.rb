class Role::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @roles = find_roles
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(RoleSerializer.new(@roles,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @roles.total_pages,
      total_rows: @roles.total_count,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Role)
    allowed_fields = [:role]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @field = result.fields
  end

  def find_roles
    roles = Role.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      roles = roles.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      roles = roles.where(filter.to_query)
    end
    if @sort.present?
      roles = roles.order(@sort)
    else
      roles = roles.order(name: :asc)
    end
    roles
  end

end
