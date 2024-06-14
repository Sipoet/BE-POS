class Ipos::PurchaseOrder < ApplicationRecord
  self.table_name = 'tbl_pesanhd'
  self.primary_key = 'iddetailtrs'

  has_many :purchase_order_items, class_name:'Ipos::PurchaseOrderItem',  foreign_key: 'notransaksi', primary_key: 'notransaksi',dependent: :destroy

end
