class CreateMonthSalesPerformanceReports < ActiveRecord::Migration[7.1]
  def up
    ActiveRecord::Base.connection.execute <<-SQL
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
        SUM(sales_total) AS sales_total
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
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS month_sales_performance_reports;
    SQL
  end
end
