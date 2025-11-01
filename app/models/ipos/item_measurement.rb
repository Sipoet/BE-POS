class Ipos::ItemMeasurement < ApplicationRecord
  self.table_name = 'tbl_itemsatuan'
  self.primary_key = 'iddetail'

  belongs_to :item, class_name: 'Ipos::Item', foreign_key: 'kodeitem', primary_key: 'kodeitem'
end
