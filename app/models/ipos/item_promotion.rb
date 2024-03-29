class Ipos::ItemPromotion < ApplicationRecord
  self.table_name = 'tbl_itemdispdt'
  self.primary_key = ['kodeitem','iddiskon']
  default_scope { order(iddiskon: :asc) }
  belongs_to :promotion, class_name: 'Promotion', foreign_key: 'iddiskon'
  belongs_to :item, foreign_key: 'kodeitem', primary_key: 'kodeitem'

  def discount
    discount_code = iddiskon.split('_')[1..-1].join rescue nil
    Discount.find_by(code: iddiskon.split('_')[1..-1].join)
  end
end
