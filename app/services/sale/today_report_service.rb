class Sale::TodayReportService < BaseService

  def execute_service
    query = execute_sql(query_report)
    render_json({data:query.to_a.first})
  end

  private

  def query_report
    <<~SQL
    select sum(totalakhir) AS sales_total,
    count(*) as num_of_transaction,
    sum(jmldebit) AS debit_total,
    sum(jmlkk) AS credit_total,
    sum(case when jmltunai > 0 then totalakhir else 0 end) AS cash_total,
    sum(case when byr_emoney_prod = 'QRIS' then jmlemoney else 0 end) AS qris_total,
    sum(case when byr_emoney_prod = 'online transfer' then jmlemoney else 0 end) AS online_total
    from #{Sale.table_name} where tanggal between '#{Time.now.utc.beginning_of_day}' and '#{Time.now.utc.end_of_day}'
    SQL
  end
  def today_range
    (Time.now.utc.beginning_of_day)..(Time.now.end_of_day)
  end
end
