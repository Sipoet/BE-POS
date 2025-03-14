class Sale::DailyTransactionReportService < ApplicationService

  def execute_service
    extract_params
    sales_transaction_reports = find_daily_transaction_reports
    render_json(SalesTransactionReportSerializer.new(sales_transaction_reports))
  end

  private

  def extract_params
    @start_date ||= @params.fetch(:start_date,Date.today).try(:to_date)
    @end_date ||= @params.fetch(:end_date,Date.today).try(:to_date)
  end

  def find_daily_transaction_reports
    query_result = ApplicationRecord.connection.execute(query_report)
    query_result.to_a.map do |row|
      row['start_time'] = row['date'].to_date.beginning_of_day
      row['end_time'] = row['start_time'].end_of_day
      SalesTransactionReport.new(row)
    end
  end

  def query_report
    sale_table = Ipos::Sale.table_name
    sale_item_table = Ipos::SaleItem.table_name
    start_time = Time.parse("#{@start_date.iso8601} 00:00:00Z")
    end_time = Time.parse("#{@end_date.iso8601} 23:59:59.999Z")
    <<~SQL
    SELECT DATE_TRUNC('day',#{sale_table}.tanggal) AS date,
    ROUND(COALESCE(SUM(totalakhir),0),0) AS sales_total,
    ROUND(COALESCE(SUM(group_sale.discount_total), 0) + COALESCE(sum(potnomfaktur), 0),0) AS discount_total,
    ROUND(COALESCE(SUM(totalakhir) - SUM(hpp_total),0),0) AS gross_profit,
    ROUND(COALESCE(count(*),0),0) AS num_of_transaction,
    ROUND(COALESCE(SUM(jmldebit),0),0) AS debit_total,
    ROUND(COALESCE(SUM(jmlkk),0),0) AS credit_total,
    ROUND(COALESCE(SUM(case when jmltunai > 0 then totalakhir else 0 end),0),0) AS cash_total,
    ROUND(COALESCE(SUM(case when byr_emoney_prod = 'QRIS' then jmlemoney else 0 end),0),0) AS qris_total,
    ROUND(COALESCE(SUM(case when byr_emoney_prod = 'online transfer' then jmlemoney else 0 end),0),0) AS online_total
    FROM #{sale_table}
    INNER JOIN (
      SELECT notransaksi,
      SUM(jumlah * harga) - sum(total) AS discount_total,
      SUM(jumlah * tbl_item.hargapokok) AS hpp_total
      FROM #{Ipos::SaleItem.table_name}
      INNER JOIN tbl_item on tbl_item.kodeitem = tbl_ikdt.kodeitem
      GROUP BY notransaksi
    )group_sale ON group_sale.notransaksi = #{sale_table}.notransaksi
    WHERE tanggal BETWEEN '#{start_time}' AND '#{end_time}' AND #{sale_table}.tipe in('KSR','JL')
    GROUP BY
      DATE_TRUNC('day',#{sale_table}.tanggal)
    SQL
  end

end
