class PayrollType < ApplicationRecord


  validates :name, presence: true
  validates :initial, presence: true
  validates :order, presence: true, numericality:{greater_than: 0,integer: true}
end
