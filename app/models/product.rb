class Product < ApplicationRecord

  belongs_to :supplier
  belongs_to :brand
  belongs_to :item_type

  has_many :tags, through: :product_tags
  has_many :stock_keeping_units

end
