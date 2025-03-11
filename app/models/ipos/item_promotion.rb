class Ipos::ItemPromotion < ApplicationRecord
  self.table_name = 'tbl_itemdispdt'
  self.primary_key = ['kodeitem','iddiskon']
  default_scope { order(iddiskon: :asc) }
  belongs_to :promotion, class_name: 'Ipos::Promotion', foreign_key: 'iddiskon'
  belongs_to :item, class_name:'Ipos::Item', foreign_key: 'kodeitem', primary_key: 'kodeitem'
  belongs_to :costumer_group, optional: true, foreign_key: :kgruppel, primary_key: :kgrup, class_name:'Ipos::CustomerGroup'

  has_one :discount, through: :promotion
end
