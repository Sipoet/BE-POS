class BookPayslipLine::IndexService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    @book_payslip_lines = find_book_payslip_lines
    options = {
      meta: meta,
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(BookPayslipLineSerializer.new(@book_payslip_lines, options))
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_rows: @book_payslip_lines.total_count,
      total_pages: @book_payslip_lines.total_pages
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(BookPayslipLine)
    allowed_fields = %i[book_payslip_line employee payroll_type]
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

  def find_book_payslip_lines
    book_payslip_lines = BookPayslipLine.all.includes(@query_included).joins(:employee, :payroll_type)
                                        .page(@page)
                                        .per(@limit)
    if @search_text.present?
      book_payslip_lines = book_payslip_lines.where(['employees.code ilike ? OR employees.name ilike ? OR payroll_types.name ilike ?'] + Array.new(
        3, "%#{@search_text}%"
      ))
    end
    @filters.each do |filter|
      book_payslip_lines = filter.add_filter_to_query(book_payslip_lines)
    end
    if @sort.present?
      book_payslip_lines.order(@sort)
    else
      book_payslip_lines.order(id: :asc)
    end
  end
end
