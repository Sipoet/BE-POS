class Ipos::Purchase < ApplicationRecord
  self.table_name = 'tbl_imhd'
  self.primary_key = 'notransaksi'

  has_many :item_purchase, class_name:'Ipos::ItemPurchase',  foreign_key: 'notransaksi', primary_key: 'notransaksi',dependent: :destroy
  belongs_to :purchase_order, class_name: 'Ipos::PurchaseOrder', foreign_key: 'notrsorder', primary_key: 'notransaksi'
end
