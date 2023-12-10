class Report::ItemSalesPercentageService < BaseService
  require 'write_xlsx'
  PER_LIMIT = 1000.freeze
  LOCALE_SCOPE = 'item_sales_percentage_report.model'.freeze


  def execute_service
    I18n.locale = :id
    filter = get_filter
    query_generator = ItemSalesPercentageReport.all

    page = @params[:page]
    data = []
    if page.present?
      paginated_query = query_generator.generate_sql_query(page: page.to_i, per: (@params[:per] || PER_LIMIT).to_i)
      data = execute_and_decorate_sql(paginated_query)
    else
      page = 1
      loop do
        paginated_query = query_generator.generate_sql_query(page: page, per: PER_LIMIT)
        query_results = execute_and_decorate_sql(paginated_query)
        break if query_results.empty?
        data += query_results
        page += 1
      end
    end

    case @params[:report_type]
    when 'xlsx'
      file_excel = generate_excel(data,filter)
      @controller.send_file file_excel
    when 'json'
      options = {
        meta:{
          column_names: localized_column_names,
          column_order: ItemSalesPercentageReport::TABLE_HEADER,
          filter: filter
        }
      }
      render_json(ItemSalesPercentageSerializer.new(data,options).serializable_hash)
    end
  end

  private

  def localized_column_names
    @localized_column_names ||= ItemSalesPercentageReport::TABLE_HEADER.map{|column_name| I18n.t(column_name, scope: LOCALE_SCOPE)}
  end

  def generate_excel(rows, filter)
    file = Tempfile.new([filename,'.xlsx'])
    workbook = WriteXLSX.new(file.path)
    insert_to_sheet_data(workbook,rows)
    insert_metadata(workbook, filter)
    workbook.close
    file
  end

  def insert_to_sheet_data(workbook,rows)
    worksheet = workbook.add_worksheet('data')
    add_header(workbook,worksheet)
    add_data(workbook,worksheet,rows)
  end

  def insert_metadata(workbook, filter)
    worksheet = workbook.add_worksheet('metadata')
    label_format = workbook.add_format(bold: true, align: 'right')
    datetime_format = workbook.add_format(num_format: 'dd mmmm yyyy hh:mm')
    filter_format = workbook.add_format(bold: true, align: 'right', size: 14)
    worksheet.set_column(0,0,20, label_format)
    worksheet.set_column(1,1,25)
    worksheet.set_column(3,3,20, label_format)
    worksheet.write_string(0,0, 'Report generated at :')
    worksheet.write_date_time('B1', DateTime.now.iso8601[0..18], datetime_format)
    worksheet.write_string(1,0, 'FILTER', filter_format)
    index = 2
    filter.each do |key, value|
      worksheet.write_string(index,0, "#{key} :")
      worksheet.write_string(index,1, value.is_a?(Array) ? value.join(', ') : value.to_s)
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

  def add_header(workbook,worksheet)
    header_format = workbook.add_format(bold: true, size: 14)
    worksheet.set_row(0,22,header_format)
    localized_column_names.each.with_index(1) do |header_name,index|
      col_number = get_column_number(index)
      worksheet.write("#{col_number}1", header_name,header_format)
    end
  end

  def add_data(workbook,worksheet,rows)
    num_format = workbook.add_format(size: 12, num_format: '#,##0')
    general_format = workbook.add_format(size: 12)
    worksheet.set_column(5,8,24,num_format)
    worksheet.set_column(0,4,17,general_format)
    worksheet.set_column(1,1,45)
    worksheet.set_column(9,9,20,general_format)
    rows.each.with_index(1) do |row, index_vertical|
      ItemSalesPercentageReport::TABLE_HEADER.each.with_index(0) do |key,index|
        value = row.send(key)
        if value.is_a?(String)
          worksheet.write_string(index_vertical,index, value)
        else
          worksheet.write_number(index_vertical,index, value)
        end
      end
    end
  end

  def filename
    'Laporan-penjualan-persentase'
  end

  def get_filter
    permitted_params = @params.permit(brands: [],item_codes: [],item_types: [],suppliers: [])
    [:brands,:item_codes, :item_types, :suppliers].each_with_object({}) do |key,filter|
      filter[key] = permitted_params[key] if permitted_params[key].present?
    end
  end

  def execute_and_decorate_sql(sql)
    results = execute_sql(sql)
    results.to_a.map{|row| ItemSalesPercentageReport.new(row)}
  end
end
