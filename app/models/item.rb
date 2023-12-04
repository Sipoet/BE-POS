class Item < ApplicationRecord
  self.table_name = "tbl_item"
  self.primary_key = 'kodeitem'
  paginates_per 20
end
