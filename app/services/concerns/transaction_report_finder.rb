module TransactionReportFinder
  extend ActiveSupport::Concern
  included do
    def summary_sales_transaction(start_time: DateTime.parse("#{Date.today}Z"),
                                  end_time: DateTime.parse("#{Date.today}Z").end_of_day)
      sql = query_report(start_time, end_time)
      query = ApplicationRecord.connection.execute(sql)
      sales_transaction_report = SalesTransactionReport.new(query.to_a.first)
      sales_transaction_report.start_time = start_time
      sales_transaction_report.end_time = end_time
      sales_transaction_report
    end
  end

  private

  def query_report(start_time, end_time)
    <<~SQL
      SELECT ROUND(COALESCE(SUM(totalakhir),0),0) AS sales_total,
      ROUND(COALESCE(SUM(group_sale.discount_total), 0) + COALESCE(sum(potnomfaktur), 0),0) AS discount_total,
      ROUND(COALESCE(SUM(totalakhir) - SUM(hpp_total),0),0) AS gross_profit,
      ROUND(COALESCE(count(*),0),0) AS num_of_transaction,
      ROUND(COALESCE(SUM(jmldebit),0),0) AS debit_total,
      ROUND(COALESCE(SUM(jmlkk),0),0) AS credit_total,
      ROUND(COALESCE(SUM(case when jmltunai > 0 then totalakhir else 0 end),0),0) AS cash_total,
      ROUND(COALESCE(SUM(case when byr_emoney_prod = 'QRIS' then jmlemoney else 0 end),0),0) AS qris_total,
      ROUND(COALESCE(SUM(case when byr_emoney_prod = 'online transfer' then jmlemoney else 0 end),0),0) AS online_total
      FROM #{Ipos::Sale.table_name}
      INNER JOIN (
        SELECT notransaksi,
        SUM(jumlah * harga) - sum(total) AS discount_total,
        SUM(jumlah * tbl_item.hargapokok) AS hpp_total
        FROM #{Ipos::SaleItem.table_name}
        INNER JOIN tbl_item on tbl_item.kodeitem = tbl_ikdt.kodeitem
        GROUP BY notransaksi
      )group_sale ON group_sale.notransaksi = #{Ipos::Sale.table_name}.notransaksi
      WHERE tanggal between '#{start_time}' and '#{end_time}' and #{Ipos::Sale.table_name}.tipe in('KSR','JL')
    SQL
  end
end
