class User::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @users = find_users
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(UserSerializer.new(@users, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @users.total_pages,
      total_rows: @users.total_count
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(User)
    allowed_includes = %i[role user]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: User)
  end

  def find_users
    users = User.all.includes(@included)
                .page(@page)
                .per(@limit)
    users = users.where(['username ilike ? '] + Array.new(1, "%#{@search_text}%")) if @search_text.present?
    @filters.each do |filter|
      users = users.where(filter.to_query)
    end
    if @sort.present?
      users.order(@sort)
    else
      users.order(username: :asc)
    end
  end
end
