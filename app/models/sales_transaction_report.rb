class SalesTransactionReport < ApplicationModel


  attr_accessor :start_time,
                :end_time,
                :sales_total,
                :num_of_transaction,
                :discount_total,
                :cash_total,
                :debit_total,
                :credit_total,
                :qris_total,
                :online_total,
                :gross_profit

  def initialize(row)
    @start_time = row['start_time']
    @end_time = row['end_time']
    @sales_total = row['sales_total']
    @num_of_transaction = row['num_of_transaction'].to_i
    @discount_total = row['discount_total']
    @cash_total = row['cash_total']
    @debit_total = row['debit_total']
    @credit_total = row['credit_total']
    @qris_total = row['qris_total']
    @online_total = row['online_total']
    @gross_profit = row['gross_profit']
  end

  def id
    @start_time
  end

  def subtotal
    sales_total - discount_total
  end
end
