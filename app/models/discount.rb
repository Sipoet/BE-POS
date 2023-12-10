require 'override/big_decimal.rb'
class Discount < ApplicationRecord
  attr_readonly :code

  validates :code, presence: true
  validates :discount1, presence: true, numericality:{greater_than: 0}
  validates :start_time, presence: true
  validates :end_time, presence: true

  validate :range_time_should_valid

  private

  def range_time_should_valid
    return unless [start_time, end_time].all?
    if start_time > end_time
      errors.add(:start_time, :greater_than,count: end_time)
      errors.add(:end_time, :less_than,count: start_time)
    end
  end

end
