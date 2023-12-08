class ItemSalesPercentageQuery

  def initialize(brands:[], suppliers:[], item_types:[], item_codes:[])
    @brands = *brands
    @suppliers = *suppliers
    @item_types = *item_types
    @item_codes = *item_codes
  end

  def generate_sql_query(page: 1, per: nil)
    query = main_query
    if per.present?
      offset = calculate_offset(page,per)
      query +=" offset #{offset} limit #{per}"
    end
    query
  end

  private

  def main_query
    return @main_query if @main_query.present?
    @main_query = """select tbl_item.kodeitem as item_code, tbl_item.namaitem as item_name, tbl_item.jenis as item_type,
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
    if @brands.present?
      query_filter << ApplicationRecord.sanitize_sql(["merek in (?)", @brands])
    end
    if @suppliers.present?
      query_filter << ApplicationRecord.sanitize_sql(["supplier1 in (?)", @suppliers])
    end
    if @item_types.present?
      query_filter << ApplicationRecord.sanitize_sql(["jenis in (?)", @item_types])
    end
    if @item_codes.present?
      query_filter << ApplicationRecord.sanitize_sql(["kodeitem in (?)", @item_codes])
    end
    if query_filter.present?
      @main_query += " where #{query_filter.join(' AND ')}"
    end
    @main_query +=" ORDER BY tbl_item.kodeitem asc"
    @main_query
  end

  def calculate_offset(page,per)
    (page - 1) * per
  end

  def sanitize_sql(sql)
    ApplicationRecord.sanitize_sql(sql)
  end
end
