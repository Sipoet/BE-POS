class SalesTransactionReportSerializer
  include JSONAPI::Serializer
  attributes :start_time,
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
end
