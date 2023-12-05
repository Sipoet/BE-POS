class Report::ItemSalesPercentageService < BaseService
  require 'write_xlsx'
  PER_PAGE = 1000.freeze

  def execute_service
    filter = get_filter
    query = generate_sql_query(filter)
    page = 1
    data = []
    loop do
      paginated_query = paginate_query(query: query ,page: page, per: PER_PAGE)
      query_results = execute_sql(paginated_query)
      query_results = query_results.to_a
      break if query_results.empty?
      data += query_results
      page += 1
    end
    file_excel = generate_excel(data,filter)
    @controller.send_file file_excel
  end

  private

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
    dozens = index / ALPHABETS.length
    col_number = ALPHABETS[(dozens - 1)] if dozens >= 1
    col_number += ALPHABETS[(unit - 1)]
    col_number
  end

  def add_header(workbook,worksheet)
    header_format = workbook.add_format(bold: true, size: 14)
    worksheet.set_row(0,22,header_format)

    (TABLE_HEADER + EXT_HEADER).each.with_index(1) do |header_name,index|
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
      TABLE_HEADER.each.with_index(0) do |key,index|
        value = row[key.to_s]
        if value.is_a?(String)
          worksheet.write_string(index_vertical,index, value)
        else
          worksheet.write_number(index_vertical,index, value)
        end
      end
      percentage = percentage_sales(row)
      worksheet.write_string(index_vertical, TABLE_HEADER.length, percentage)
    end
  end

  def percentage_sales(row)
    value = row['number_of_purchase'] == 0 ? 0 : (row['number_of_sales'].to_f / row['number_of_purchase'].to_f * 100).round(2)
    "#{value}%"
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

  TABLE_HEADER = [
    'item_code',
    'item_name',
    'item_type',
    'supplier',
    'brand',
    'sell_price',
    'avg_buy_price',
    'number_of_sales',
    'sales_total',
    'number_of_purchase',
    'purchase_total',
  ].freeze
  EXT_HEADER = [
    'percentage_sales',
  ]

  def generate_sql_query(filter)
    query = """select tbl_item.kodeitem as item_code, tbl_item.namaitem as item_name, tbl_item.jenis as item_type,
    tbl_item.supplier1 as supplier,
    tbl_item.merek as brand,
    tbl_item.hargajual1 as sell_price,
    coalesce(purchase.avg_buy_price,beginning_stock.avg_buy_price) as avg_buy_price,
    coalesce(sales.number_of_sales,0) as number_of_sales,
    coalesce(sales.sales_total,0) as sales_total,
    coalesce(purchase.number_of_purchase,0) + coalesce(beginning_stock.number_of_purchase,0) as number_of_purchase,
    coalesce(purchase.purchase_total,0) + coalesce(beginning_stock.purchase_total,0) as purchase_total
    from tbl_item
    left outer join(
      select kodeitem,
      sum(tbl_ikdt.jumlah) as number_of_sales,
      sum(tbl_ikdt.total) as sales_total
      from tbl_ikdt
      group by kodeitem
    )sales on sales.kodeitem = tbl_item.kodeitem
	left outer join (
		select kodeitem,
      	sum(tbl_imdt.jumlah) as number_of_purchase,
        avg(tbl_imdt.harga) as avg_buy_price,
      	sum(tbl_imdt.total) as purchase_total
      	from tbl_imdt
		group by kodeitem
	)purchase on purchase.kodeitem = tbl_item.kodeitem and purchase.number_of_purchase > 0
	left outer join (
		select kodeitem,
      	sum(tbl_item_sa.jumlah) as number_of_purchase,
        avg(tbl_item_sa.harga) as avg_buy_price,
      	sum(tbl_item_sa.total) as purchase_total
      	from tbl_item_sa
		group by kodeitem
	)beginning_stock on beginning_stock.kodeitem = tbl_item.kodeitem and beginning_stock.number_of_purchase > 0
    """
    query_filter = []
    return query if filter.keys.empty?
    if filter[:brands].present?
      query_filter << ApplicationRecord.sanitize_sql(["merek in (?)",filter[:brands])
    end
    if filter[:suppliers].present?
      query_filter << ApplicationRecord.sanitize_sql(["supplier1 in (?)",filter[:supplier1])
    end
    if filter[:item_types].present?
      query_filter << ApplicationRecord.sanitize_sql(["jenis in (?)",filter[:item_types])
    end
    if filter[:item_codes].present?
      query_filter << ApplicationRecord.sanitize_sql(["kodeitem in (?)",filter[:item_codes])
    end
    query += " where #{query_filter.join(' AND ')}"
    query +=" ORDER BY tbl_item.kodeitem asc"

  end
end
