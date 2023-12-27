class ItemSale < ApplicationRecord
  self.table_name = 'tbl_ikdt'
  self.primary_key = ['notransaksi','kodeitem']

  belongs_to :item, foreign_key: :kodeitem, primary_key: :kodeitem
  belongs_to :sale, foreign_key: :notransaksi, primary_key: :notransaksi
end
