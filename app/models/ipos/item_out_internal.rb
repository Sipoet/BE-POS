class Ipos::ItemOutInternal < ApplicationRecord
  self.table_name = 'tbl_item_ik'
  self.primary_key = 'iddetail'

  belongs_to :item, class_name: 'Ipos::Item', foreign_key: 'kodeitem', primary_key: 'kodeitem'
  belongs_to :office, class_name: 'Ipos::Location', foreign_key: 'kodekantor', primary_key: 'kodekantor'
end
