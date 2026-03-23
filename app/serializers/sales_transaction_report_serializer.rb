class SalesTransactionReportSerializer
  include JSONAPI::Serializer

  include TextFormatter

  attributes :sales_total,
             :num_of_transaction,
             :num_of_item,
             :discount_total,
             :cash_total,
             :debit_total,
             :credit_total,
             :qris_total,
             :online_total,
             :gross_profit,
             :start_time,
             :end_time

  # [:start_time,:end_time].each do |key|
  #   attribute key do |obj|
  #     ipos_fix_date_timezone(obj.send(key))
  #   end
  # end
end
