class Ipos::ItemPromotion < ApplicationRecord
  self.table_name = 'tbl_itemdispdt'
  self.primary_key = ['kodeitem','iddiskon']
  default_scope { order(iddiskon: :asc) }
  belongs_to :promotion, class_name: 'Promotion', foreign_key: 'iddiskon'
  belongs_to :item, foreign_key: 'kodeitem', primary_key: 'kodeitem'
end
