class ItemSalesPerformanceReport < ApplicationRecord
  self.table_name = 'item_sales_performance_reports'
  self.primary_key = 'date_pk'
  include MaterializedView

  belongs_to :item, foreign_key: :item_code, primary_key: :kodeitem, class_name:'Ipos::Item'
end
