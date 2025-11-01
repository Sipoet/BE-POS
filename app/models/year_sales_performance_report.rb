class YearSalesPerformanceReport < ApplicationRecord
  self.table_name = 'year_sales_performance_reports'
  self.primary_key = %w[item_code sales_year]
  include MaterializedView
end
