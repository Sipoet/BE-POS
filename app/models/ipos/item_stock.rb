class Ipos::ItemStock < ApplicationRecord
  self.table_name = "tbl_itemstok"
  self.primary_key = ['kodeitem','kantor']
end
