class Ipos::PurchaseItem < ApplicationRecord
  self.table_name = 'tbl_imdt'
  self.primary_key = 'iddetail'

  belongs_to :purchase, class_name:'Ipos::Purchase',  primary_key: 'notransaksi', foreign_key: 'notransaksi'
  belongs_to :item, class_name:'Ipos::Item', primary_key: 'kodeitem', foreign_key: 'kodeitem'
end
