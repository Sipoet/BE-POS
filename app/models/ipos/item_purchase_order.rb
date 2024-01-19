class Ipos::ItemPurchaseOrder < ApplicationRecord
  self.table_name = 'tbl_pesandt'
  self.primary_key = 'iddetail'

  belongs_to :purchase_order, class_name:'Ipos::PurchaseOrder',  primary_key: 'notransaksi', foreign_key: 'notransaksi'

end
