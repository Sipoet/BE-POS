class ItemPromotion < ApplicationRecord
  self.table_name = "tbl_itemdispdt"
  default_scope { order(iddiskon: :asc) }
  belongs_to :promotion, class_name: "Promotion", foreign_key: "iddiskon"
end
