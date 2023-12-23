require 'big_decimal.rb'
class Discount < ApplicationRecord

  TABLE_HEADER = [
    :code,
    :supplier_code,
    :item_type,
    :brand_name,
    :item_code,
    :discount1,
    :discount2,
    :discount3,
    :discount4,
    :start_time,
    :end_time
  ].freeze

  attr_readonly :code

  validates :code, presence: true
  validates :discount1, presence: true, numericality:{greater_than_and_equal_to: 0, less_than: 100}
  validates :discount2, presence: true, numericality:{greater_than_and_equal_to: 0, less_than: 100}
  validates :discount3, presence: true, numericality:{greater_than_and_equal_to: 0, less_than: 100}
  validates :discount4, presence: true, numericality:{greater_than_and_equal_to: 0, less_than: 100}
  validates :start_time, presence: true
  validates :end_time, presence: true

  validate :range_time_should_valid
  validate :filter_should_be_filled

  scope :active_today, ->{where(start_time: ..(Time.zone.now),end_time: (Time.zone.now)..)}

  private

  # filter should be filled at least one
  def filter_should_be_filled
    return true if [item_code,item_type,supplier_code,brand_name].any?
    errors.add(:base,"Salah satu filter(#{Discount.human_attribute_name(:item_code)}, #{Discount.human_attribute_name(:item_type)}, #{Discount.human_attribute_name(:supplier_code)}, #{Discount.human_attribute_name(:brand_name)}) harus diisi")
  end

  def range_time_should_valid
    return unless [start_time, end_time].all?
    if start_time > end_time
      errors.add(:start_time, :greater_than,count: end_time)
      errors.add(:end_time, :less_than,count: start_time)
    end
  end

end
