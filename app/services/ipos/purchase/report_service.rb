class Ipos::Purchase::ReportService < ApplicationService
  LIMIT_ROWS_PER_REQUEST = 2_000
  include JsonApiDeserializer
  def execute_service
    extract_params
    @purchase_report = find_purchase_reports
    case @report_type
    when 'xlsx'
      file_excel = generate_excel(@purchase_report)
      @controller.send_file file_excel
    when 'json'
      options = {
        meta: {
          filter: @filter,
          page: @page,
          limit: @limit,
          total_pages: @purchase_report.total_pages,
          total_rows: @purchase_report.total_count
        },
        fields: @fields,
        params: { include: @included },
        include: @included
      }
      render_json(PurchaseReportSerializer.new(@purchase_report, options))
    end
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @purchase_report.total_pages,
      total_rows: @purchase_report.total_count
    }
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(PurchaseReport)
    allowed_fields = %i[purchase supplier]
    result = dezerialize_table_params(params,
                                      allowed_fields: allowed_fields,
                                      table_definitions: @table_definitions)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = result.fields
    @report_type = @params[:report_type].to_s
  end

  def find_purchase_reports
    purchase_reports = PurchaseReport.all.includes(@included)
    purchase_reports = if @report_type == 'json'
                         purchase_reports.page(@page)
                                         .per(@limit)
                       else
                         purchase_reports.page(1)
                                         .per(LIMIT_ROWS_PER_REQUEST)
                       end
    if @search_text.present?
      purchase_reports = purchase_reports.where(['code ilike ? '] + Array.new(1, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      purchase_reports = purchase_reports.where(filter.to_query)
    end
    if @sort.present?
      purchase_reports.order(@sort)
    else
      purchase_reports.order(purchase_date: :desc)
    end
  end

  def generate_excel(rows)
    generator = ExcelGenerator.new
    generator.add_column_definitions(@table_definitions.column_definitions)
    generator.add_data(rows)
    generator.add_metadata(@filter || {})
    generator.generate('laporan-pembelian')
  end

  def meta
    {
      page: @page,
      limit: @limit,
      total_pages: @purchase_report.total_pages,
      total_rows: @purchase_report.total_count
    }
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(PurchaseReport)
    allowed_includes = %i[purchase supplier]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = filter_authorize_fields(fields: result.fields, record_class: PurchaseReport)
    @report_type = @params[:report_type].to_s
  end

  def find_purchase_reports
    purchase_reports = PurchaseReport.all.includes(@included)
    purchase_reports = if @report_type == 'json'
                         purchase_reports.page(@page)
                                         .per(@limit)
                       else
                         purchase_reports.page(1)
                                         .per(LIMIT_ROWS_PER_REQUEST)
                       end
    if @search_text.present?
      purchase_reports = purchase_reports.where(['code ilike ? '] + Array.new(1, "%#{@search_text}%"))
    end
    @filters.each do |filter|
      purchase_reports = purchase_reports.where(filter.to_query)
    end
    if @sort.present?
      purchase_reports.order(@sort)
    else
      purchase_reports.order(purchase_date: :desc)
    end
  end

  def generate_excel(rows)
    generator = ExcelGenerator.new
    generator.add_column_definitions(@table_definition.column_definitions)
    generator.add_data(rows)
    generator.add_metadata(@filter || {})
    generator.generate('laporan-pembelian')
  end
end
