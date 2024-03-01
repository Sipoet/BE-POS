class Ipos::Brand < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:merek, :string),
    datatable_column(self,:ketmerek, :string),
  ]
  self.table_name = 'tbl_itemmerek'
  self.primary_key = 'merek'
end
