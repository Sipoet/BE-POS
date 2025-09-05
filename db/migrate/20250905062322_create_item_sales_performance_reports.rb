class CreateItemSalesPerformanceReports < ActiveRecord::Migration[7.1]
  def up
     first_fiscal_year = 2023
    ActiveRecord::Base.connection.execute <<-SQL
      CREATE MATERIALIZED VIEW item_sales_performance_reports AS (
        SELECT
          CONCAT(sales.kodeitem, '-', sales.tahun, '-', sales.bulan, '-', sales.hari, '-', sales.jam) AS pk_code,
          sales.kodeitem AS item_code,
          COALESCE(purchase.tahun_beli,#{first_fiscal_year}) AS last_purchase_year,
          sales.jam AS sales_hour,
          sales.hari AS sales_day,
          sales.minggu AS sales_week,
          sales.hari_dalam_minggu AS sales_day_in_week,
          sales.bulan AS sales_month,
          sales.tahun AS sales_year,
          sales.jumlah_barang AS sales_quantity,
          sales.jumlah_diskon_penjualan AS sales_discount_quantity,
          sales.total_penjualan AS sales_total
        FROM (
          SELECT tbl_ikdt.kodeitem,
            sale_header.jam,
            sale_header.hari,
            sale_header.minggu,
			      sale_header.hari_dalam_minggu,
            sale_header.bulan,
            sale_header.tahun,
            ROUND(SUM(tbl_ikdt.jumlah),2) AS jumlah_barang,
            ROUND(SUM((tbl_ikdt.jumlah * tbl_ikdt.harga) - tbl_ikdt.total),2) AS jumlah_diskon_penjualan,
            SUM(tbl_ikdt.total) AS total_penjualan
          FROM tbl_ikdt
          INNER JOIN (
            SELECT tbl_ikhd.notransaksi,
            date_part('hour',tbl_ikhd.tanggal)as jam,
            date_part('day',tbl_ikhd.tanggal) AS hari,
            date_part('dow',tbl_ikhd.tanggal) AS hari_dalam_minggu,
            date_part('week',tbl_ikhd.tanggal) AS minggu,
            date_part('month',tbl_ikhd.tanggal) AS bulan,
            date_part('year',tbl_ikhd.tanggal) AS tahun
            FROM tbl_ikhd
            WHERE tbl_ikhd.tipe IN ('KSR','JL')
          )sale_header ON tbl_ikdt.notransaksi = sale_header.notransaksi
          GROUP BY
            tbl_ikdt.kodeitem,
            sale_header.jam,
            sale_header.hari,
            sale_header.minggu,
            sale_header.bulan,
            sale_header.tahun,
			sale_header.hari_dalam_minggu
        ) sales
        LEFT OUTER JOIN (
          SELECT tbl_imdt.kodeitem,
            MAX(DATE_PART('year',tbl_imhd.tanggal)) AS tahun_beli
          FROM tbl_imdt
          INNER JOIN tbl_imhd ON tbl_imdt.notransaksi = tbl_imhd.notransaksi
          WHERE tbl_imhd.tipe IN ('BL','KI')
          GROUP BY tbl_imdt.kodeitem
        ) purchase ON purchase.kodeitem = sales.kodeitem
        ORDER BY sales.kodeitem ASC
      );
      CREATE UNIQUE INDEX u_idx_ispr
        ON item_sales_performance_reports (pk_code);
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS item_sales_performance_reports;
    SQL
  end
end
