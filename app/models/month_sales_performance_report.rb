class MonthSalesPerformanceReport < ApplicationRecord
  self.table_name = 'month_sales_performance_reports'
  self.primary_key = ['item_code', 'date_pk']
  extend MaterializedView
end
