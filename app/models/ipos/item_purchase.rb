class Ipos::ItemPurchase < ApplicationRecord
  self.table_name = 'tbl_imdt'
  self.primary_key = 'iddetail'

  belongs_to :purchase, class_name:'Ipos::Purchase',  primary_key: 'notransaksi', foreign_key: 'notransaksi'

end
