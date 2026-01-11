class CashierSession::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @cashier_sessions = find_cashier_sessions
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(CashierSessionSerializer.new(@cashier_sessions, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @cashier_sessions.total_pages,
      total_rows: @cashier_sessions.total_count
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(CashierSession)
    allowed_includes = [:cashier_session]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: CashierSession)
  end

  def find_cashier_sessions
    cashier_sessions = CashierSession.all.includes(@included)
                                     .page(@page)
                                     .per(@limit)
    # if @search_text.present?
    #   cashier_sessions = cashier_sessions.where(['name ilike ? '] + Array.new(1, "%#{@search_text}%"))
    # end
    @filters.each do |filter|
      cashier_sessions = cashier_sessions.where(filter.to_query)
    end
    if @sort.present?
      cashier_sessions.order(@sort)
    else
      cashier_sessions.order(date: :asc)
    end
  end
end
