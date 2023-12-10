class CreateItemSalesPercentageView < ActiveRecord::Migration[7.1]
  def up
    ActiveRecord::Base.connection.execute """
    CREATE VIEW item_sales_percentage_reports AS (select tbl_item.kodeitem as item_code, tbl_item.namaitem as item_name, tbl_item.jenis as item_type,
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
	)beginning_stock on beginning_stock.kodeitem = tbl_item.kodeitem and beginning_stock.number_of_purchase > 0)
    """
  end

  def down
    ActiveRecord::Base.connection.execute "DROP VIEW IF EXISTS item_sales_percentage_reports"
  end
end
