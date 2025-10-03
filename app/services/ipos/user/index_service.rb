class Ipos::User::IndexService < ApplicationService

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
    render_json(Ipos::UserSerializer.new(@users,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @users.total_count,
       total_pages: @users.total_pages,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::User)
    allowed_fields = [:user]
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

  def find_users
    users = Ipos::User.all.includes(@query_included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      users = users.where(['userid ilike ? OR nama ilike ?']+ Array.new(2,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      users = filter.add_filter_to_query(users)
    end
    if @sort.present?
      users = users.order(@sort)
    else
      users = users.order(id: :asc)
    end
    users
  end

end
