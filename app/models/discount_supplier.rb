class DiscountSupplier < ApplicationRecord
  belongs_to :supplier,  foreign_key: :supplier_code, primary_key: :kode, class_name: 'Ipos::Supplier'
  belongs_to :discount, inverse_of: :discount_suppliers

  scope :included_suppliers, -> { where(is_exclude: false) }
  scope :excluded_suppliers, -> { where(is_exclude: true) }

  validates :supplier, presence: true
end
