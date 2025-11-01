class CreateMonthlyExpenseReports < ActiveRecord::Migration[7.1]
  def up
    ActiveRecord::Base.connection.execute <<-SQL
      CREATE MATERIALIZED VIEW monthly_expense_reports AS (
        SELECT
          CONCAT(year,'-',month,'-1')::DATE AS date_pk,
          month,
          year,
          SUM(subtotal) as total
        from (
          SELECT
            date_part('month',tanggal)::INTEGER AS month,
            date_part('year',tanggal)::INTEGER AS year,
            subtotal
          FROM tbl_acckashd
          WHERE tipe='KASO'
        ) cashout
        GROUP BY
          year,
          month
        ORDER BY date_pk ASC
      );
      CREATE UNIQUE INDEX u_idx_mer
      ON monthly_expense_reports (date_pk);
    SQL
  end

  def down
    ActiveRecord::Base.connection.execute <<-SQL
      DROP MATERIALIZED VIEW IF EXISTS monthly_expense_reports CASCADE;
    SQL
  end
end
