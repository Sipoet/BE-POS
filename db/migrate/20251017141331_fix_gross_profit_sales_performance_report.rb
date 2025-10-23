class FixGrossProfitSalesPerformanceReport < ActiveRecord::Migration[7.1]
  def up
    first_fiscal_year = 2023
    ActiveRecord::Base.connection.execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS item_sales_performance_reports CASCADE;
      CREATE MATERIALIZED VIEW item_sales_performance_reports AS (
        SELECT
          CONCAT(sales.kodeitem, '-', sales.sales_year, '-', sales.sales_month, '-', sales.sales_day, '-', sales.sales_hour) AS pk_code,
          CONCAT(sales_year,'-',to_char(sales_month,'FM00'),'-',to_char(sales_day,'FM00'),'T',to_char(sales_hour,'FM00'),':00')::TIMESTAMP as date_pk,
          sales.kodeitem AS item_code,
          COALESCE(purchase.tahun_beli,#{first_fiscal_year}) AS last_purchase_year,
          tbl_item.merek AS brand_name,
          tbl_item.supplier1 AS supplier_code,
          tbl_item.jenis AS item_type_name,
          sales.sales_hour,
          sales.sales_day,
          sales.sales_week,
          sales.sales_day_of_week,
          sales.sales_month,
          sales.sales_year,
          sales.sales_quantity,
          sales.sales_discount_amount,
          sales.sales_total,
          sales.debit_total,
          sales.credit_total,
          sales.cash_total,
          sales.qris_total,
          sales.online_total,
          sales.gross_profit
        FROM tbl_item
        INNER JOIN (
          SELECT tbl_ikdt.kodeitem,
            sale_header.sales_hour,
            sale_header.sales_day,
            sale_header.sales_week,
			      sale_header.sales_day_of_week,
            sale_header.sales_month,
            sale_header.sales_year,
            ROUND(SUM(tbl_ikdt.jumlah),2) AS sales_quantity,
            ROUND(SUM((tbl_ikdt.jumlah * tbl_ikdt.harga) - tbl_ikdt.total - sale_header.header_discount_total * tbl_ikdt.jumlah/ sale_header.totalitem),2) AS sales_discount_amount,
            SUM(tbl_ikdt.total) AS sales_total,
            SUM(sale_header.debit_total) AS debit_total,
            SUM(sale_header.credit_total) AS credit_total,
            SUM(sale_header.cash_total) AS cash_total,
            SUM(sale_header.qris_total) AS qris_total,
            SUM(sale_header.online_total) AS online_total,
            SUM(tbl_ikdt.total) - SUM(cogs_detail.cogs_total) - SUM(sale_header.header_discount_total * tbl_ikdt.jumlah/ sale_header.totalitem) AS gross_profit
          FROM tbl_ikdt
          INNER JOIN (
            SELECT
              tbl_item_ik.tanggal,
              tbl_item_ik.iddetailtrs,
              round(SUM(tbl_item_ik.jumlahdasar * tbl_item_im.hargadasar),0) AS cogs_total
            FROM tbl_item_ik
            INNER JOIN tbl_item_im ON tbl_item_ik.iddetailim = tbl_item_im.iddetail
            GROUP BY
              tbl_item_ik.tanggal,
              tbl_item_ik.iddetailtrs
          ) cogs_detail
          ON tbl_ikdt.iddetail = cogs_detail.iddetailtrs
          INNER JOIN (
            SELECT tbl_ikhd.notransaksi,
            date_part('hour',tbl_ikhd.tanggal)::INTEGER as sales_hour,
            date_part('day',tbl_ikhd.tanggal)::INTEGER AS sales_day,
            date_part('dow',tbl_ikhd.tanggal)::INTEGER AS sales_day_of_week,
            date_part('week',tbl_ikhd.tanggal)::INTEGER AS sales_week,
            date_part('month',tbl_ikhd.tanggal)::INTEGER AS sales_month,
            date_part('year',tbl_ikhd.tanggal)::INTEGER AS sales_year,
            COALESCE(jmldebit,0) AS debit_total,
            COALESCE(jmlkk,0) AS credit_total,
            COALESCE(potnomfaktur,0) AS header_discount_total,
            totalitem,
            COALESCE(case when jmltunai > 0 then totalakhir else 0 end,0) AS cash_total,
            COALESCE(case when byr_emoney_prod = 'QRIS' then jmlemoney else 0 end,0) AS qris_total,
            COALESCE(case when byr_emoney_prod = 'online transfer' then jmlemoney else 0 end,0) AS online_total
            FROM tbl_ikhd
            WHERE tbl_ikhd.tipe IN ('KSR','JL')
          )sale_header ON tbl_ikdt.notransaksi = sale_header.notransaksi
          GROUP BY
            tbl_ikdt.kodeitem,
            sale_header.sales_hour,
            sale_header.sales_day,
            sale_header.sales_week,
			      sale_header.sales_day_of_week,
            sale_header.sales_month,
            sale_header.sales_year
        ) sales ON sales.kodeitem = tbl_item.kodeitem
        LEFT OUTER JOIN (
          SELECT tbl_imdt.kodeitem,
            MAX(DATE_PART('year',tbl_imhd.tanggal))::INTEGER AS tahun_beli
          FROM tbl_imdt
          INNER JOIN tbl_imhd ON tbl_imdt.notransaksi = tbl_imhd.notransaksi
          WHERE tbl_imhd.tipe IN ('BL','KI')
          GROUP BY tbl_imdt.kodeitem
        ) purchase ON purchase.kodeitem = sales.kodeitem
        ORDER BY sales.kodeitem ASC
      );
      CREATE UNIQUE INDEX u_idx_ispr
        ON item_sales_performance_reports (pk_code);
      CREATE MATERIALIZED VIEW day_sales_performance_reports AS (
        SELECT
          tbl_item.kodeitem as item_code,
          merek AS brand_name,
          jenis AS item_type_name,
          supplier1 AS supplier_code,
          last_purchase_year,
          sales_year,
          sales_month,
          sales_day,
          CONCAT(sales_year,'-',to_char(sales_month,'FM00'),'-',to_char(sales_day,'FM00'))::DATE as date_pk,
          SUM(sales_quantity) AS sales_quantity,
          SUM(sales_discount_amount) AS sales_discount_amount,
          SUM(sales_total) AS sales_total,
          SUM(debit_total) AS debit_total,
          SUM(credit_total) AS credit_total,
          SUM(cash_total) AS cash_total,
          SUM(qris_total) AS qris_total,
          SUM(online_total) AS online_total,
          SUM(gross_profit) AS gross_profit
        FROM item_sales_performance_reports
        inner join tbl_item on tbl_item.kodeitem = item_sales_performance_reports.item_code
        GROUP BY
          tbl_item.kodeitem,
          last_purchase_year,
          sales_year,
          sales_month,
          sales_day
    );
    CREATE UNIQUE INDEX u_idx_dspr
      ON day_sales_performance_reports (item_code,last_purchase_year,date_pk);
    CREATE MATERIALIZED VIEW week_sales_performance_reports AS (
      SELECT
        tbl_item.kodeitem as item_code,
        merek AS brand_name,
        jenis AS item_type_name,
        supplier1 AS supplier_code,
        last_purchase_year,
        sales_year,
        sales_week,
        CONCAT(sales_year,'-',to_char(sales_week,'FM00')) as date_pk,
        SUM(sales_quantity) AS sales_quantity,
        SUM(sales_discount_amount) AS sales_discount_amount,
        SUM(sales_total) AS sales_total,
        SUM(debit_total) AS debit_total,
        SUM(credit_total) AS credit_total,
        SUM(cash_total) AS cash_total,
        SUM(qris_total) AS qris_total,
        SUM(online_total) AS online_total,
        SUM(gross_profit) AS gross_profit
      FROM item_sales_performance_reports
      inner join tbl_item on tbl_item.kodeitem = item_sales_performance_reports.item_code
      GROUP BY
        tbl_item.kodeitem,
        last_purchase_year,
        sales_year,
        sales_week
    );
    CREATE UNIQUE INDEX u_idx_wspr
      ON week_sales_performance_reports (item_code,last_purchase_year,date_pk);
    CREATE MATERIALIZED VIEW month_sales_performance_reports AS (
      SELECT
        tbl_item.kodeitem as item_code,
        merek AS brand_name,
        jenis AS item_type_name,
        supplier1 AS supplier_code,
        last_purchase_year,
        sales_year,
        sales_month,
        CONCAT(sales_year,'-',to_char(sales_month,'FM00'),'-','01')::DATE as date_pk,
        SUM(sales_quantity) AS sales_quantity,
        SUM(sales_discount_amount) AS sales_discount_amount,
        SUM(sales_total) AS sales_total,
        SUM(debit_total) AS debit_total,
        SUM(credit_total) AS credit_total,
        SUM(cash_total) AS cash_total,
        SUM(qris_total) AS qris_total,
        SUM(online_total) AS online_total,
        SUM(gross_profit) AS gross_profit
      FROM item_sales_performance_reports
      inner join tbl_item on tbl_item.kodeitem = item_sales_performance_reports.item_code
      GROUP BY
        tbl_item.kodeitem,
        last_purchase_year,
        sales_year,
        sales_month
    );
    CREATE UNIQUE INDEX u_idx_mspr
      ON month_sales_performance_reports (item_code,last_purchase_year,date_pk);
    CREATE MATERIALIZED VIEW year_sales_performance_reports AS (
      SELECT
        tbl_item.kodeitem as item_code,
        merek AS brand_name,
        jenis AS item_type_name,
        supplier1 AS supplier_code,
        last_purchase_year,
        sales_year,
        SUM(sales_quantity) AS sales_quantity,
        SUM(sales_discount_amount) AS sales_discount_amount,
        SUM(sales_total) AS sales_total,
        SUM(debit_total) AS debit_total,
        SUM(credit_total) AS credit_total,
        SUM(cash_total) AS cash_total,
        SUM(qris_total) AS qris_total,
        SUM(online_total) AS online_total,
        SUM(gross_profit) AS gross_profit
      FROM item_sales_performance_reports
      inner join tbl_item on tbl_item.kodeitem = item_sales_performance_reports.item_code
      GROUP BY
        tbl_item.kodeitem,
        last_purchase_year,
        sales_year
    );
    CREATE UNIQUE INDEX u_idx_yspr
      ON year_sales_performance_reports (item_code,last_purchase_year,sales_year);
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS item_sales_performance_reports CASCADE;
    SQL
    migrator = ActiveRecord::MigrationContext.new(ActiveRecord::Migrator.migrations_paths)
    migrator.up(20251001171048)
  end
end
