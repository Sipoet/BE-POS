class Sale < ApplicationRecord
  self.table_name = 'tbl_ikhd'
  self.primary_key = 'notransaksi'

  has_many :item_sales, class_name: 'ItemSale',foreign_key: :notransaksi, dependent: :destroy, inverse_of: :sale
end
