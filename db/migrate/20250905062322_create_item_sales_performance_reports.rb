class CreateItemSalesPerformanceReports < ActiveRecord::Migration[7.1]
  def up
     first_fiscal_year = 2023
    ActiveRecord::Base.connection.execute <<-SQL
      CREATE MATERIALIZED VIEW item_sales_performance_reports AS (
        SELECT
          CONCAT(sales.kodeitem, '-', sales.sales_year, '-', sales.sales_month, '-', sales.sales_day, '-', sales.sales_hour) AS pk_code,
          CONCAT(sales_year,'-',to_char(sales_month,'FM00'),'-',to_char(sales_day,'FM00'),'T',to_char(sales_hour,'FM00'),':00')::DATE as date_pk,
          sales.kodeitem AS item_code,
          COALESCE(purchase.tahun_beli,#{first_fiscal_year}) AS last_purchase_year,
          tbl_item.merek AS brand_name,
          tbl_item.supplier1 AS supplier_code,
          tbl_item.jenis AS item_type_name,
          sales.sales_hour,
          sales.sales_day,
          sales.sales_week,
          sales.sales_day_in_week,
          sales.sales_month,
          sales.sales_year,
          sales.sales_quantity,
          sales.sales_discount_amount,
          sales.sales_total
        FROM tbl_item
        INNER JOIN (
          SELECT tbl_ikdt.kodeitem,
            sale_header.sales_hour,
            sale_header.sales_day,
            sale_header.sales_week,
			      sale_header.sales_day_in_week,
            sale_header.sales_month,
            sale_header.sales_year,
            ROUND(SUM(tbl_ikdt.jumlah),2) AS sales_quantity,
            ROUND(SUM((tbl_ikdt.jumlah * tbl_ikdt.harga) - tbl_ikdt.total),2) AS sales_discount_amount,
            SUM(tbl_ikdt.total) AS sales_total
          FROM tbl_ikdt
          INNER JOIN (
            SELECT tbl_ikhd.notransaksi,
            date_part('hour',tbl_ikhd.tanggal)::INTEGER as sales_hour,
            date_part('day',tbl_ikhd.tanggal)::INTEGER AS sales_day,
            date_part('dow',tbl_ikhd.tanggal)::INTEGER AS sales_day_in_week,
            date_part('week',tbl_ikhd.tanggal)::INTEGER AS sales_week,
            date_part('month',tbl_ikhd.tanggal)::INTEGER AS sales_month,
            date_part('year',tbl_ikhd.tanggal)::INTEGER AS sales_year
            FROM tbl_ikhd
            WHERE tbl_ikhd.tipe IN ('KSR','JL')
          )sale_header ON tbl_ikdt.notransaksi = sale_header.notransaksi
          GROUP BY
            tbl_ikdt.kodeitem,
            sale_header.sales_hour,
            sale_header.sales_day,
            sale_header.sales_week,
			      sale_header.sales_day_in_week,
            sale_header.sales_month,
            sale_header.sales_year
        ) sales ON sales.kodeitem = tbl_item.kodeitem
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
