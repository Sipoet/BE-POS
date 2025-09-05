class CreateDaySalesPerformanceReports < ActiveRecord::Migration[7.1]
  def migrate_group_day_view
    ActiveRecord::Base.connection.execute <<-SQL
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
        CONCAT(sales_year,'-',to_char(sales_month,'FM00'),'-',to_char(sales_day,'FM00')) as date_pk,
        SUM(sales_quantity) AS sales_quantity,
        SUM(sales_discount_quantity) AS sales_discount_quantity,
        SUM(sales_total) AS sales_total
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
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS day_sales_performance_reports;
    SQL
  end

end
