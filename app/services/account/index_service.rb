class Account::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @accounts = find_accounts
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(Ipos::AccountSerializer.new(@accounts,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @accounts.total_count,
       total_pages: @accounts.total_pages,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Ipos::Account)
    allowed_fields = [:account]
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

  def find_accounts
    accounts = Ipos::Account.all.includes(@query_included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      accounts = accounts.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      accounts = filter.add_filter_to_query(accounts)
    end
    if @sort.present?
      accounts = accounts.order(@sort)
    else
      accounts = accounts.order(id: :asc)
    end
    accounts
  end

end
