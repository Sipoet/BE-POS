class Sale::TodayReportService < BaseService

  def execute_service
    query = execute_sql(query_report)
    render_json({data:query.to_a.first})
  end

  private

  def query_report
    <<~SQL
    select coalesce(sum(totalakhir),0) AS sales_total,
    coalesce(sum(subtotal) - sum(totalakhir),0) AS discount_total,
    coalesce(count(*),0) as num_of_transaction,
    coalesce(sum(jmldebit),0) AS debit_total,
    coalesce(sum(jmlkk),0) AS credit_total,
    coalesce(sum(case when jmltunai > 0 then totalakhir else 0 end),0) AS cash_total,
    coalesce(sum(case when byr_emoney_prod = 'QRIS' then jmlemoney else 0 end),0) AS qris_total,
    coalesce(sum(case when byr_emoney_prod = 'online transfer' then jmlemoney else 0 end),0) AS online_total
    from #{Sale.table_name} where tanggal between '#{start_time}' and '#{end_time}'
    SQL
  end

  def start_time
    @start_time ||= @params.fetch(:start_time,Time.now.utc.beginning_of_day).try(:to_time)
  end

  def end_time
    @end_time ||= @params.fetch(:end_time,Time.now.utc.end_of_day).try(:to_time)
  end
end
