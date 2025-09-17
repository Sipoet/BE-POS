class CreateDaySalesTrafficReports < ActiveRecord::Migration[7.1]
  def up
    ActiveRecord::Base.connection.execute <<-SQL
    CREATE MATERIALIZED VIEW day_sales_traffic_reports AS (
      SELECT
        CONCAT(sales_year,'-',to_char(sales_month,'FM00'),'-',to_char(sales_day,'FM00'),'-',to_char(sales_hour,'FM00')) as date_pk,
        CONCAT(sales_year,'-',to_char(sales_month,'FM00'),'-',to_char(sales_day,'FM00'))::date as transaction_date,
        sales_hour,
        sales_day_of_week,
        SUM(sales_quantity) AS sales_quantity,
        SUM(sales_discount_amount) AS sales_discount_amount,
        SUM(sales_total) AS sales_total
      FROM item_sales_performance_reports
      inner join tbl_item on tbl_item.kodeitem = item_sales_performance_reports.item_code
      GROUP BY
        sales_year,
        sales_month,
        sales_day,
        sales_hour,
        sales_day_of_week
    );
    CREATE UNIQUE INDEX u_idx_dstr
      ON day_sales_traffic_reports (date_pk);
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS day_sales_traffic_reports;
    SQL
  end
end
