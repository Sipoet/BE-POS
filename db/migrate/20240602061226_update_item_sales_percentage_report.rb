class UpdateItemSalesPercentageReport < ActiveRecord::Migration[7.1]
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
        ROUND(tbl_item.hargajual1,0) AS sell_price,
        stok.warehouse_stock,
        stok.store_stock,
        purchase.recent_purchase_date,
        ROUND(COALESCE(purchase.avg_buy_price,beginning_stock.avg_buy_price),2) AS avg_buy_price,
        ROUND(COALESCE(sales.number_of_sales,0),0) AS number_of_sales,
        ROUND(COALESCE(sales.sales_total,0),0) AS sales_total,
        ROUND(COALESCE(sales.sales_total,0) - (COALESCE(purchase.avg_buy_price,beginning_stock.avg_buy_price) * COALESCE(sales.number_of_sales,0)),0) AS gross_profit,
        ROUND(COALESCE(sales.item_out,0),0) AS item_out,
        ROUND(COALESCE(purchase.number_of_purchase,0) + COALESCE(beginning_stock.number_of_purchase,0),0) AS number_of_purchase,
        COALESCE(purchase.purchase_total,0) + COALESCE(beginning_stock.purchase_total,0) AS purchase_total
      FROM tbl_item
      INNER JOIN tbl_supel ON tbl_supel.kode = tbl_item.supplier1 AND tbl_supel.tipe = 'SU'
      INNER JOIN tbl_itemjenis ON tbl_itemjenis.jenis = tbl_item.jenis
      LEFT OUTER JOIN(
        SELECT kodeitem,
        SUM(CASE WHEN tbl_ikhd.tipe IN('KSR','JL') then tbl_ikdt.jumlah ELSE 0 END) AS number_of_sales,
        SUM(CASE WHEN tbl_ikhd.tipe IN('KSR','JL') then tbl_ikdt.total - (tbl_ikdt.total/tbl_ikhd.subtotal*tbl_ikhd.potnomfaktur) ELSE 0 END) AS sales_total,
        SUM(CASE WHEN tbl_ikhd.tipe = 'IK' then tbl_ikdt.jumlah ELSE 0 END) AS item_out
        FROM tbl_ikdt
        INNER JOIN tbl_ikhd ON tbl_ikhd.notransaksi = tbl_ikdt.notransaksi
        GROUP BY kodeitem
      )sales ON sales.kodeitem = tbl_item.kodeitem
      LEFT OUTER JOIN (
        SELECT kodeitem,
        MAX(tbl_imhd.tanggal) as recent_purchase_date,
        SUM(tbl_imdt.jumlah) AS number_of_purchase,
        AVG(tbl_imdt.harga) AS avg_buy_price,
        SUM(tbl_imdt.total) AS purchase_total
        FROM tbl_imdt
        INNER JOIN tbl_imhd on tbl_imhd.notransaksi = tbl_imdt.notransaksi
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
        SUM(case when kantor = 'GDG' then round(stok,1) else 0 end) AS warehouse_stock,
        SUM(case when kantor = 'TOKO' then round(stok,1) else 0 end) AS store_stock
        FROM tbl_itemstok
        GROUP BY
        kodeitem
      )stok ON stok.kodeitem = tbl_item.kodeitem
    )
    """
  end

  def down
    ActiveRecord::Base.connection.execute """
    DROP VIEW IF EXISTS item_sales_percentage_reports;
    CREATE VIEW item_sales_percentage_reports AS (
      SELECT
        tbl_item.kodeitem AS item_code,
        tbl_item.namaitem AS item_name,
        tbl_item.jenis AS item_type,
		    tbl_itemjenis.ketjenis AS item_type_desc,
        tbl_item.supplier1 AS supplier_code,
		    tbl_supel.nama AS supplier_name,
        tbl_item.merek AS brand,
        tbl_item.hargajual1 AS sell_price,
        stok.warehouse_stock,
        stok.store_stock,
        purchase.recent_purchase_date,
        coalesce(purchase.avg_buy_price,beginning_stock.avg_buy_price) AS avg_buy_price,
        ROUND(coalesce(sales.number_of_sales,0),0) AS number_of_sales,
        coalesce(sales.sales_total,0) AS sales_total,
        ROUND(coalesce(sales.item_out,0),0) AS item_out,
        ROUND(coalesce(purchase.number_of_purchase,0) + coalesce(beginning_stock.number_of_purchase,0),0) AS number_of_purchase,
        coalesce(purchase.purchase_total,0) + coalesce(beginning_stock.purchase_total,0) AS purchase_total
      FROM tbl_item
      INNER JOIN tbl_supel ON tbl_supel.kode = tbl_item.supplier1 AND tbl_supel.tipe = 'SU'
      INNER JOIN tbl_itemjenis ON tbl_itemjenis.jenis = tbl_item.jenis
      LEFT OUTER JOIN(
        SELECT kodeitem,
        SUM(CASE WHEN tbl_ikhd.tipe IN('KSR','JL') then tbl_ikdt.jumlah ELSE 0 END) AS number_of_sales,
        SUM(CASE WHEN tbl_ikhd.tipe IN('KSR','JL') then tbl_ikdt.total ELSE 0 END) AS sales_total,
        SUM(CASE WHEN tbl_ikhd.tipe = 'IK' then tbl_ikdt.jumlah ELSE 0 END) AS item_out
        FROM tbl_ikdt
        INNER JOIN tbl_ikhd ON tbl_ikhd.notransaksi = tbl_ikdt.notransaksi
        GROUP BY kodeitem
      )sales ON sales.kodeitem = tbl_item.kodeitem
      LEFT OUTER JOIN (
        SELECT kodeitem,
          MAX(tbl_imhd.tanggal) as recent_purchase_date,
          SUM(tbl_imdt.jumlah) AS number_of_purchase,
          AVG(tbl_imdt.harga) AS avg_buy_price,
          SUM(tbl_imdt.total) AS purchase_total
        FROM tbl_imdt
        INNER JOIN tbl_imhd on tbl_imhd.notransaksi = tbl_imdt.notransaksi
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
          SUM(case when kantor = 'GDG' then round(stok,1) else 0 end) AS warehouse_stock,
          SUM(case when kantor = 'TOKO' then round(stok,1) else 0 end) AS store_stock
        FROM tbl_itemstok
        GROUP BY
          kodeitem
      )stok ON stok.kodeitem = tbl_item.kodeitem
    )
    """
  end
end
