class CashTransactionReport::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @cash_transaction_reports = find_cash_transaction_reports
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(CashTransactionReportSerializer.new(@cash_transaction_reports, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @cash_transaction_reports.total_count,
      total_pages: @cash_transaction_reports.total_pages
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(CashTransactionReport)
    allowed_fields = %i[cash_transaction_report detail_account payment_account]
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

  def find_cash_transaction_reports
    cash_transaction_reports = CashTransactionReport.all.includes(@query_included)
                                                    .page(@page)
                                                    .per(@limit)
    if @search_text.present?
      cash_transaction_reports = cash_transaction_reports.left_outer_joins(:payment_account,
                                                                           :detail_account)
                                                         .where(['description ilike ? OR tbl_perkiraan.namaacc ilike ? OR detail_accounts_cash_transaction_reports.namaacc ilike ?'] + Array.new(
                                                           3, "%#{@search_text}%"
                                                         ))
    end
    @filters.each do |filter|
      cash_transaction_reports = filter.add_filter_to_query(cash_transaction_reports)
    end
    if @sort.present?
      cash_transaction_reports.order(@sort)
    else
      cash_transaction_reports.order(id: :asc)
    end
  end
end
