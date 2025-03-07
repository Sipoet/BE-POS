class DiscountGroupItem < ApplicationRecord

  belongs_to :item_report, foreign_key: :item_code
  belongs_to :item, foreign_key: :item_code, primary_key: :kodeitem
  belongs_to :discount_rule
end
