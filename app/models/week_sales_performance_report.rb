class WeekSalesPerformanceReport < ApplicationRecord
  self.table_name = 'week_sales_performance_reports'
  self.primary_key = ['item_code', 'date_pk']
  include MaterializedView
end
