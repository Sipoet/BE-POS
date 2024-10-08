class SalesTransactionReport < ApplicationModel

  TABLE_HEADER = [
    datatable_column(self,:start_time, :date),
    datatable_column(self,:end_time, :date),
    datatable_column(self,:sales_total, :money),
    datatable_column(self,:gross_profit, :money),
    datatable_column(self,:num_of_transaction, :integer),
    datatable_column(self,:discount_total, :money),
    datatable_column(self,:cash_total, :money),
    datatable_column(self,:debit_total, :money),
    datatable_column(self,:credit_total, :money),
    datatable_column(self,:qris_total, :money),
    datatable_column(self,:online_total, :money),
  ].freeze

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
    @start_time = row['start_time'].try(:to_datetime)
    @end_time = row['end_time'].try(:to_datetime)
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
