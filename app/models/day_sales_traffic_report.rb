class DaySalesTrafficReport < ApplicationRecord
  self.table_name = 'day_sales_traffic_reports'
  self.primary_key = 'date_pk'
  include MaterializedView
end
