class Ipos::PurchaseOrder < ApplicationRecord
  self.table_name = 'tbl_pesanhd'
  self.primary_key = 'iddetailtrs'

  has_many :item_purchase_order, class_name:'Ipos::ItemPurchaseOrder',  foreign_key: 'notransaksi', primary_key: 'notransaksi',dependent: :destroy

end
