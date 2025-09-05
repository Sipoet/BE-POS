class CreateYearSalesPerformanceReports < ActiveRecord::Migration[7.1]
  def up
    ActiveRecord::Base.connection.execute <<-SQL
    CREATE MATERIALIZED VIEW year_sales_performance_reports AS (
      SELECT
        tbl_item.kodeitem as item_code,
        merek AS brand_name,
        jenis AS item_type_name,
        supplier1 AS supplier_code,
        last_purchase_year,
        sales_year,
        SUM(sales_quantity) AS sales_quantity,
        SUM(sales_discount_quantity) AS sales_discount_quantity,
        SUM(sales_total) AS sales_total
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
      DROP MATERIALIZED VIEW IF EXISTS year_sales_performance_reports;
    SQL
  end
end
