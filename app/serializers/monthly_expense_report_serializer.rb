class MonthlyExpenseReportSerializer
  include JSONAPI::Serializer
  attributes :date_pk, :year, :month, :total
end
