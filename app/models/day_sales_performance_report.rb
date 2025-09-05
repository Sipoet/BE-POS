class DaySalesPerformanceReport < ApplicationRecord
  self.table_name = 'day_sales_performance_reports'
  self.primary_key = ['item_code', 'date_pk']
  extend MaterializedView
end
