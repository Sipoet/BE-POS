# frozen_string_literal: true

class ItemSalesPercentageReport::IndexService < ApplicationService
  require 'write_xlsx'
  include JsonApiDeserializer
  PER_LIMIT = 1000.freeze

  def execute_service
    extract_params
    reports = find_reports
    case @report_type
    when 'xlsx'
      file_excel = generate_excel(reports)
      @controller.send_file file_excel
    when 'json'
      options = {
        meta: {
          filter: @filter,
          page: @page,
          limit: @limit,
           total_pages: reports.total_pages,
          total_rows: reports.total_count,
        },
        fields: @fields,
        params:{include: @included},
        include: @included
      }
      render_json(ItemSalesPercentageReportSerializer.new(reports, options))
    end
  end

  private

  def extract_params
    allowed_columns = ItemSalesPercentageReport::TABLE_HEADER.map(&:name)
    allowed_fields = [:item, :item_type, :supplier, :brand]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @page = result.page || 1
    @limit = result.limit || 20
    @search_text = result.search_text
    @sort = result.sort
    @included = result.included
    @filters = result.filters
    @fields = result.fields
    @report_type = @params[:report_type].to_s
  end

  def find_reports
    reports = ItemSalesPercentageReport.all.includes(@included)
    if @report_type == 'json'
      reports = reports.page(@page).per(@limit)
    end
    @filters.each do |filter|
      reports = reports.where(filter.to_query)
    end
    if @sort.present?
      reports = reports.order(@sort)
    else
      reports = reports.order(item_code: :asc)
    end
    reports
  end

  def generate_excel(rows)
    generator = ExcelGenerator.new
    generator.add_column_definitions(ItemSalesPercentageReport::TABLE_HEADER)
    generator.add_data(rows)
    generator.add_metadata(@filter || {})
    generator.generate('laporan-item')
  end


end
