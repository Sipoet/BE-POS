# frozen_string_literal: true

class ItemSalesPercentageReport::IndexService < ApplicationService
  require 'write_xlsx'
  PER_LIMIT = 1000.freeze

  def execute_service
    filter = fetch_filter
    reports = find_reports(filter)
    page = @params[:page]
    if page.present?
      reports = reports.page(page.to_i)
                       .per((@params[:per] || PER_LIMIT).to_i)
    end
    case @params[:report_type].to_s
    when 'xlsx'
      file_excel = generate_excel(reports, filter)
      @controller.send_file file_excel
    when 'json'
      options = {
        meta: {
          filter: filter
        }
      }
      render_json(ItemSalesPercentageReportSerializer.new(reports, options))
    end
  end

  private

  def find_reports(filter)
    query = ItemSalesPercentageReport.order(item_code: :asc)
    query = query.where(brand: filter[:brands]) if filter[:brands].present?
    query = query.where(supplier_code: filter[:suppliers]) if filter[:suppliers].present?
    query = query.where(item_type: filter[:item_types]) if filter[:item_types].present?
    query = query.where(item_code: filter[:item_codes]) if filter[:item_codes].present?
    query
  end

  def generate_excel(rows, filter)
    generator = ExcelGenerator.new
    generator.add_column_definitions(target_class::TABLE_HEADER)
    generator.add_data(rows)
    generator.add_metadata(filter)
    generator.generate('laporan-penjualan-item')
  end

  def fetch_filter
    permitted_params = @params.permit(brands: [], item_codes: [], item_types: [], suppliers: [])
    %i[brands item_codes item_types suppliers].each_with_object({}) do |key, filter|
      filter[key] = permitted_params[key] if permitted_params[key].present?
    end
  end
end
