class Ipos::ItemType < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:jenis, :string),
    datatable_column(self,:ketjenis, :string),
  ]
  self.table_name = "tbl_itemjenis"
  self.primary_key = 'jenis'
end
