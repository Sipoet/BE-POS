class WeekSalesPerformanceReport < ApplicationRecord
  self.table_name = 'week_sales_performance_reports'
  self.primary_key = %w[item_code date_pk]
  include MaterializedView
end
