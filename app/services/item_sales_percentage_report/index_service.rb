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
    query = query.where(brand_name: filter[:brands]) if filter[:brands].present?
    query = query.where(supplier_code: filter[:suppliers]) if filter[:suppliers].present?
    query = query.where(item_type_name: filter[:item_types]) if filter[:item_types].present?
    query = query.where(item_code: filter[:item_codes]) if filter[:item_codes].present?
    if filter[:warehouse_stock].present?
      sign_symbol, num = filter[:warehouse_stock].split('-')
      query = query.where("warehouse_stock #{comparion_sign(sign_symbol)} ?",num.to_i)
    end
    if filter[:store_stock].present?
      sign_symbol, num = filter[:store_stock].split('-')
      query = query.where("store_stock #{comparion_sign(sign_symbol)} ?",num.to_i)
    end
    query
  end

  def generate_excel(rows, filter)
    generator = ExcelGenerator.new
    generator.add_column_definitions(target_class::TABLE_HEADER)
    generator.add_data(rows)
    generator.add_metadata(filter)
    generator.generate('laporan-penjualan-item')
  end

  def comparion_sign(symbol)
    case symbol.to_sym
    when :lt then '<'
    when :gt then '>'
    when :lte then '<='
    when :gte then '>='
    when :nt then '!='
    when :eq then '='
    else '='
    end
  end

  def fetch_filter
    permitted_params = @params.permit(:warehouse_stock,:store_stock,brands: [], item_codes: [], item_types: [], suppliers: [])
    %i[warehouse_stock store_stock brands item_codes item_types suppliers].each_with_object({}) do |key, filter|
      filter[key] = permitted_params[key] if permitted_params[key].present?
    end

  end
end
