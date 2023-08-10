class Report::ItemSalesPercentageService < BaseService
  require 'csv'
  PER_PAGE = 1000.freeze

  def execute_service
    filter = get_filter  
    query = generate_sql_query(filter)
    page = 1
    @controller.response.headers['Content-Type'] = 'text/event-stream'
    stream_csv do |stream|
      loop do
        paginated_query = paginate_query(query: query ,page: page, per: PER_PAGE)
        query_results = execute_sql(paginated_query)
        break if query_results.to_a.blank?
        query_results.each do |row|
          row_data = generate_row_data(row)
          stream.write CSV.generate_line(row_data)
        end
        page += 1
      end
    end
  end

  private

  def generate_row_data(row)
    row_data = TABLE_HEADER.map {|column_name| row[column_name.to_s]}
    percentage_sales = row['number_of_purchase'] == 0 ? 0 : row['number_of_sales'].to_f / row['number_of_purchase'].to_f * 100
    row_data << "#{percentage_sales}%"
    row_data
  end

  def stream_csv(&block)
    @controller.send_stream(filename: filename, type: 'text/event-stream', disposition: 'attachment') do |stream|
      stream.write CSV.generate_line(TABLE_HEADER + EXT_HEADER)
      block.call stream
    end
  end

  def filename
    @filename ||= "Laporan-penjualan-#{Time.zone.now.iso8601}.csv"
  end

  def get_filter
    [:brands,:item_codes, :item_types, :suppliers].each_with_object({}) do |key,filter|
      filter[key] = @params[key] if @params[key].present?
    end
  end

  TABLE_HEADER = [
    'item_code',
    'item_name',
    'item_type',
    'supplier',
    'brand',
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
      	sum(tbl_imdt.total) as purchase_total
      	from tbl_imdt
		group by kodeitem
	)purchase on purchase.kodeitem = tbl_item.kodeitem and purchase.number_of_purchase > 0
	left outer join (
		select kodeitem, 
      	sum(tbl_item_sa.jumlah) as number_of_purchase,
      	sum(tbl_item_sa.total) as purchase_total
      	from tbl_item_sa
		group by kodeitem
	)beginning_stock on beginning_stock.kodeitem = tbl_item.kodeitem and beginning_stock.number_of_purchase > 0
    order by tbl_item.kodeitem asc
    """
    return query if filter.keys.empty?
    if filter[:brands].present?
      value_string = filter[:brands].join('","')
      query_filter << "merek in (#{value_string})"
    end
    if filter[:supplier].present?
      value_string = filter[:suppliers].join('","')
      query_filter << "supplier1 in (#{value_string})"
    end
    if filter[:item_types].present?
      value_string = filter[:item_types].join('","')
      query_filter << "tipe in (#{value_string})"
    end
    if filter[:item_codes].present?
      value_string = filter[:item_codes].join('","')
      query_filter << "kodeitem in (#{value_string})"
    end
    query += " where #{query_filter.join(' AND ')}"
    query
  end
end