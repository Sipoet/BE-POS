# frozen_string_literal: true

class ItemSalesPercentageReport::IndexService < BaseService
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
      render_json(ItemSalesPercentageSerializer.new(reports, options))
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

  def localized_column_names
    ItemSalesPercentageReport::TABLE_HEADER.map { |column_name| ItemSalesPercentageReport.human_attribute_name(column_name) }
  end

  def generate_excel(rows, filter)
    file = Tempfile.new([filename, '.xlsx'])
    workbook = WriteXLSX.new(file.path)
    insert_to_sheet_data(workbook, rows)
    insert_metadata(workbook, filter)
    workbook.close
    file
  end

  def insert_to_sheet_data(workbook, rows)
    worksheet = workbook.add_worksheet('data')
    add_header(workbook, worksheet)
    add_data(workbook, worksheet, rows)
  end

  def insert_metadata(workbook, filter)
    worksheet = workbook.add_worksheet('metadata')
    label_format = workbook.add_format(bold: true, align: 'right')
    datetime_format = workbook.add_format(num_format: 'dd mmmm yyyy hh:mm')
    filter_format = workbook.add_format(bold: true, align: 'right', size: 14)
    worksheet.set_column(0, 0, 20, label_format)
    worksheet.set_column(1, 1, 25)
    worksheet.set_column(3, 3, 20, label_format)
    worksheet.write_string(0, 0, 'Report generated at :')
    worksheet.write_date_time('B1', DateTime.now.iso8601[0..18], datetime_format)
    worksheet.write_string(1, 0, 'FILTER', filter_format)
    index = 2
    filter.each do |key, value|
      worksheet.write_string(index, 0, "#{key} :")
      worksheet.write_string(index, 1, value.is_a?(Array) ? value.join(', ') : value.to_s)
      index += 1
    end
  end

  ALPHABETS = ('A'..'Z').to_a.freeze

  def get_column_number(index)
    col_number = ''
    unit = index % ALPHABETS.length
    dozens = (index / ALPHABETS.length)
    col_number = ALPHABETS[(dozens - 1)] if dozens >= 1
    col_number += ALPHABETS[(unit - 1)]
    col_number
  end

  def add_header(workbook, worksheet)
    header_format = workbook.add_format(bold: true, size: 14)
    worksheet.set_row(0, 22, header_format)
    localized_column_names.each.with_index(1) do |header_name, index|
      col_number = get_column_number(index)
      worksheet.write("#{col_number}1", header_name, header_format)
    end
  end

  def add_data(workbook, worksheet, rows)
    num_format = workbook.add_format(size: 12, num_format: '#,##0')
    general_format = workbook.add_format(size: 12)
    # worksheet.set_column(5, 8, 24, num_format)
    # worksheet.set_column(0, 4, 17, general_format)
    # worksheet.set_column(1, 1, 45)
    # worksheet.set_column(9, 9, 20, general_format)
    rows.each.with_index(1) do |row, index_vertical|
      ItemSalesPercentageReport::TABLE_HEADER.each.with_index(0) do |key, index|
        value = row.send(key)
        if value.is_a?(String)
          worksheet.write_string(index_vertical, index, value)
        else
          worksheet.write_number(index_vertical, index, value)
        end
      end
    end
  end

  def filename
    'laporan-penjualan-persentase'
  end

  def fetch_filter
    permitted_params = @params.permit(brands: [], item_codes: [], item_types: [], suppliers: [])
    %i[brands item_codes item_types suppliers].each_with_object({}) do |key, filter|
      filter[key] = permitted_params[key] if permitted_params[key].present?
    end
  end
end
