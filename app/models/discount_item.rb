class DiscountItem < ApplicationRecord

  belongs_to :item, foreign_key: :item_code, primary_key: :kodeitem, class_name: 'Ipos::Item'
  belongs_to :discount, inverse_of: :discount_items

  scope :included_items, ->{where(is_exclude: false)}
  scope :excluded_items, ->{where(is_exclude: true)}

  validates :item, presence: true
end
