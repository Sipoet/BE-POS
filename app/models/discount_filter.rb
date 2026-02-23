class DiscountFilter < ApplicationRecord
  belongs_to :discount, inverse_of: :discount_filters

  scope :included, -> { where(is_exclude: false) }
  scope :excluded, -> { where(is_exclude: true) }

  scope :items, -> { where(filter_key: 'item') }
  scope :item_types, -> { where(filter_key: 'item_type') }
  scope :brands, -> { where(filter_key: 'brand') }
  scope :suppliers, -> { where(filter_key: 'supplier') }

  validates :discount, presence: true
  validates :value, presence: true
  validates :filter_key, presence: true
end
