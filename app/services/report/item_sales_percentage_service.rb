class Report::ItemSalesPercentageService < BaseService

  def execute_service
    filter = get_filter  
    query = generate_sql_query(filter)
    query_results = execute_sql(query)
    file = create_csv(query_results)
    @controller.send_file file, filename: filename, type:'text/csv'
  end

  private

  def filename
    @filename ||= "Laporan-penjualan-#{Time.zone.now.iso8601}.csv"
  end

  def get_filter
    filter = {
      brands: @params.fetch(:brands,[]),
      item_types: @params.fetch(:item_types,[]),
      suppliers: @params.fetch(:suppliers,[]),
      codes: @params.fetch(:item_codes,[])
    }
  end

  CSV_HEADER = [
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

  def generate_sql_query(filter)
    query = """select tbl_item.kodeitem as item_code,
    tbl_item.nama as item_name, 
    tbl_item.jenis as item_type, 
    tbl_item.supplier1 as supplier, 
    tbl_item.merek as brand, 
    coalesce(sales.number_of_sales,0) as number_of_sales,
    coalesce(sales.sales_total,0) as sales_total,
    coalesce(purchase.number_of_purchase,0) as number_of_purchase,
    coalesce(purchase.purchase_total,0), as purchase_total
    from tbl_item
    left outer join(
      select tbl_item.kodeitem,
      (sum(tbl_imdt.jumlah)+sum(tbl_item_sa.jumlah)) as number_of_sales,
      (sum(tbl_imdt.total)+sum(tbl_item_sa.total)) as sales_total
      from tbl_imdt.kodeitem
      left outer join tbl_ikdt on tbl_ikdt.kodeitem = tbl_item.kodeitem
    )sales on sales.kodeitem = tbl_item.kodeitem
    left outer join (
      select tbl_item.kodeitem, 
      (sum(tbl_imdt.jumlah)+sum(tbl_item_sa.jumlah)) as number_of_purchase,
      (sum(tbl_imdt.total)+sum(tbl_item_sa.total)) as purchase_total
      from tbl_item
      left outer join tbl_item_sa on tbl_item_sa.kodeitem = tbl_item.kodeitem
      left outer join tbl_imdt on tbl_imdt.kodeitem = tbl_item.kodeitem
      group by tbl_item.kodeitem
    )purchase on purchase.kodeitem = tbl_item.kodeitem
    """
    return query if filter.keys.blank?
    query += " where "
    if filter[:brands].present?
      value_string = filter[:brands].join('","')
      query += "merek in (#{value_string})"
    end
    if filter[:supplier].present?
      value_string = filter[:suppliers].join('","')
      query += "supplier1 in (#{value_string})"
    end
    if filter[:item_types].present?
      value_string = filter[:item_types].join('","')
      query += "tipe in (#{value_string})"
    end
    if filter[:item_codes].present?
      value_string = filter[:item_codes].join('","')
      query += "kodeitem in (#{value_string})"
    end
  end

  def create_csv(query_results)
    file = TempFile.new(filename,'.csv')
    CSV.open(file.path,'w') do |csv|
      csv << CSV_HEADER
      query_results.each do |row|
        csv << CSV_HEADER.map {|column_name| row[column_name.to_s]}          
      end
    file
  end
end