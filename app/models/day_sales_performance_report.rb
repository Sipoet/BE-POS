class DaySalesPerformanceReport < ApplicationRecord
  self.table_name = 'day_sales_performance_reports'
  self.primary_key = %w[item_code date_pk]
  include MaterializedView
end
