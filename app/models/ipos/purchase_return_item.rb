class Ipos::PurchaseReturnItem < ApplicationRecord
  self.table_name = 'tbl_pesandt'
  self.primary_key = 'iddetail'

  belongs_to :purchase_return, class_name: 'Ipos::PurchaseReturn', primary_key: 'notransaksi',
                               foreign_key: 'notransaksi'
end
