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
    }
  end

  def extract_params
    allowed_columns = Role::TABLE_HEADER.map(&:name)
    allowed_fields = [:role, :column_authorizes, :access_authorizes]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @field = result.field
  end

  def find_roles
    roles = Role.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      roles = roles.where(['name ilike ? ']+ Array.new(1,"%%"))
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
