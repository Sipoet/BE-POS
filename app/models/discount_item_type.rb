class DiscountItemType < ApplicationRecord

  belongs_to :item_type, foreign_key: :item_type_name, primary_key: :jenis, class_name:'Ipos::ItemType'
  belongs_to :discount, inverse_of: :discount_item_types

  scope :included_item_types, ->{where(is_exclude: false)}
  scope :excluded_item_types, ->{where(is_exclude: true)}
  validates :item_type, presence: true
end
