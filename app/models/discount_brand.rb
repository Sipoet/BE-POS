class DiscountBrand < ApplicationRecord

  belongs_to :brand, foreign_key: :brand_name, primary_key: :merek, class_name:'Ipos::Brand'
  belongs_to :discount, inverse_of: :discount_brands

  scope :included_brands, ->{where(is_exclude: false)}
  scope :excluded_brands, ->{where(is_exclude: true)}

  validates :brand, presence: true
end
