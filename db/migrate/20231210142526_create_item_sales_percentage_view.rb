class CreateItemSalesPercentageView < ActiveRecord::Migration[7.1]
  def up
    ActiveRecord::Base.connection.execute """
    DROP VIEW IF EXISTS item_sales_percentage_reports;
    CREATE VIEW item_sales_percentage_reports AS (
      SELECT
        tbl_item.kodeitem AS item_code,
        tbl_item.namaitem AS item_name,
        tbl_item.jenis AS item_type_name,
        tbl_itemjenis.ketjenis AS item_type_desc,
        tbl_item.supplier1 AS supplier_code,
        tbl_supel.nama AS supplier_name,
        tbl_item.merek AS brand_name,
        tbl_item.satuan AS uom,
        tbl_item.konsinyasi = 'Y' AS is_consignment,
        ROUND(tbl_item.hargajual1,0) AS sell_price,
        COALESCE(stok.warehouse_stock,0) AS warehouse_stock,
        COALESCE(stok.store_stock,0) AS store_stock,
		    COALESCE(stok.stock_left,0) AS stock_left,
        purchase.last_purchase_date,
        ROUND(COALESCE(purchase.avg_buy_price,beginning_stock.avg_buy_price),2) AS avg_buy_price,
        CASE WHEN tbl_item.hargapokok > 0 THEN ROUND(tbl_item.hargajual1 / tbl_item.hargapokok,2) - 1 ELSE 0 END AS margin,
        CASE WHEN tbl_item.hargajual1 > 0 THEN 1 - ROUND(tbl_item.hargapokok / tbl_item.hargajual1,2) ELSE 0 END AS limit_profit_discount,
        ROUND(tbl_item.hargapokok,2) AS cogs,
        ROUND(COALESCE(sales.number_of_sales,0),0) AS number_of_sales,
        ROUND(COALESCE(sales.qty_return,0),0) AS qty_return,
        ROUND(COALESCE(sales.sales_total,0),0) AS sales_total,
        ROUND(COALESCE(sales.sales_total,0) - (COALESCE(purchase.avg_buy_price,beginning_stock.avg_buy_price) * COALESCE(sales.number_of_sales,0)),0) AS gross_profit,
        ROUND(COALESCE(sales.item_out,0),0) AS item_out,
        ROUND(COALESCE(purchase.number_of_purchase,0) + COALESCE(beginning_stock.number_of_purchase,0),0) AS number_of_purchase,
        COALESCE(purchase.purchase_total,0) + COALESCE(beginning_stock.purchase_total,0) AS purchase_total,
        ROUND(COALESCE(sales.number_of_sales,0) / COALESCE(NULLIF(COALESCE(purchase.number_of_purchase,0) + COALESCE(beginning_stock.number_of_purchase,0),0 ),1),2) AS percentage_sales
      FROM tbl_item
      INNER JOIN tbl_supel ON tbl_supel.kode = tbl_item.supplier1 AND tbl_supel.tipe = 'SU'
      INNER JOIN tbl_itemjenis ON tbl_itemjenis.jenis = tbl_item.jenis
      LEFT OUTER JOIN(
        SELECT kodeitem,
        SUM(CASE WHEN tbl_ikhd.tipe IN('KSR','JL') then tbl_ikdt.jumlah WHEN tbl_ikhd.tipe ='RJ' then tbl_ikdt.jumlah * -1  ELSE 0 END) AS number_of_sales,
        SUM(CASE WHEN tbl_ikhd.tipe IN('KSR','JL') then tbl_ikdt.total - (tbl_ikdt.total/tbl_ikhd.subtotal*tbl_ikhd.potnomfaktur) ELSE 0 END) AS sales_total,
        SUM(CASE WHEN tbl_ikhd.tipe = 'IK' then tbl_ikdt.jumlah ELSE 0 END) AS item_out,
        SUM(CASE WHEN tbl_ikhd.tipe = 'RJ' then tbl_ikdt.jumlah ELSE 0 END) AS qty_return
        FROM tbl_ikdt
        INNER JOIN tbl_ikhd ON tbl_ikhd.notransaksi = tbl_ikdt.notransaksi
        GROUP BY kodeitem
      )sales ON sales.kodeitem = tbl_item.kodeitem
      LEFT OUTER JOIN (
        SELECT kodeitem,
        MAX(tbl_imhd.tanggal) as last_purchase_date,
        SUM(tbl_imdt.jumlah) AS number_of_purchase,
        AVG((tbl_imdt.total / COALESCE(NULLIF(tbl_imdt.jumlah, 0), 1)) - (tbl_imdt.total * tbl_imhd.potnomfaktur / COALESCE(NULLIF(tbl_imhd.subtotal, 0), 1))) AS avg_buy_price,
        SUM(tbl_imdt.total) AS purchase_total
        FROM tbl_imdt
        INNER JOIN tbl_imhd on tbl_imhd.notransaksi = tbl_imdt.notransaksi
        WHERE tbl_imhd.tipe IN('BL','KI')
        GROUP BY kodeitem
      )purchase ON purchase.kodeitem = tbl_item.kodeitem AND purchase.number_of_purchase > 0
      LEFT OUTER JOIN (
        SELECT kodeitem,
          SUM(tbl_item_sa.jumlah) AS number_of_purchase,
          AVG(tbl_item_sa.harga) AS avg_buy_price,
          SUM(tbl_item_sa.total) AS purchase_total
          FROM tbl_item_sa
        GROUP BY kodeitem
      )beginning_stock ON beginning_stock.kodeitem = tbl_item.kodeitem AND beginning_stock.number_of_purchase > 0
      LEFT OUTER JOIN(
        SELECT
        kodeitem,
        ROUND(SUM(case when kantor = 'GDG' then stok else 0 end),1) AS warehouse_stock,
        ROUND(SUM(case when kantor = 'TOKO' then stok else 0 end),1) AS store_stock,
		    ROUND(SUM(stok),1) AS stock_left
        FROM tbl_itemstok
        GROUP BY
        kodeitem
      )stok ON stok.kodeitem = tbl_item.kodeitem
    )
    """
  end

  def down
    ActiveRecord::Base.connection.execute "DROP VIEW IF EXISTS item_sales_percentage_reports"
  end
end
