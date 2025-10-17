class MonthlyExpenseReport::IndexService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    @monthly_expense_reports = find_monthly_expense_reports
    options = {
      meta: meta,
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(MonthlyExpenseReportSerializer.new(@monthly_expense_reports,options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @monthly_expense_reports.total_count,
       total_pages: @monthly_expense_reports.total_pages,
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(MonthlyExpenseReport)
    allowed_fields = [:monthly_expense_report]
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

  def find_monthly_expense_reports
    monthly_expense_reports = MonthlyExpenseReport.all.includes(@query_included)
      .page(@page)
      .per(@limit)
    if @search_text.present?
      monthly_expense_reports = monthly_expense_reports.where(['name ilike ? ']+ Array.new(1,"%#{@search_text}%"))
    end
    @filters.each do |filter|
      monthly_expense_reports = filter.add_filter_to_query(monthly_expense_reports)
    end
    if @sort.present?
      monthly_expense_reports = monthly_expense_reports.order(@sort)
    else
      monthly_expense_reports = monthly_expense_reports.order(id: :asc)
    end
    monthly_expense_reports
  end

end
