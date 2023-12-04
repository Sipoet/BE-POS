class Promotion < ApplicationRecord
  self.table_name = "tbl_itemdisp"
  self.primary_key = 'iddiskon'
  default_scope { order(iddiskon: :asc) }
  has_many :item_promotions, class_name: "ItemPromotion", foreign_key: "iddiskon", dependent: :destroy
end
