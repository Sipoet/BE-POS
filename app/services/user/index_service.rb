class User::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @users = find_users
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(UserSerializer.new(@users,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @users.total_pages,
      total_rows: @users.total_count,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(User)
    allowed_fields = [:role,:user]
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

  def find_users
    users = User.all.includes(@included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      users = users.where(['username ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      users = users.where(filter.to_query)
    end
    if @sort.present?
      users = users.order(@sort)
    else
      users = users.order(username: :asc)
    end
    users
  end

end
