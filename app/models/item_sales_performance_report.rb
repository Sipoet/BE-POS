class ItemSalesPerformanceReport < ApplicationRecord
  self.table_name = 'item_sales_performance_reports'
  self.primary_key = 'pk_code'
  extend MaterializedView
end
