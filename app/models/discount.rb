require 'big_decimal.rb'
class Discount < ApplicationRecord

  TABLE_HEADER = [
    :code,
    :supplier_code,
    :item_type_name,
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

  belongs_to :item, optional: true, foreign_key: :item_code, primary_key: :kodeitem, class_name:'Ipos::Item'
  belongs_to :item_type, optional: true, foreign_key: :item_type_name, primary_key: :jenis, class_name:'Ipos::ItemType'
  belongs_to :brand, optional: true, foreign_key: :brand_name, primary_key: :merek, class_name:'Ipos::Brand'
  belongs_to :supplier, optional: true, foreign_key: :supplier_code, primary_key: :kode, class_name:'Ipos::Supplier'

  validate :range_time_should_valid
  validate :filter_should_be_filled

  scope :active_today, ->{where(start_time: ..(Time.now),end_time: (Time.now)..)}

  def generate_code
    self.code = [
      self.item_code,
      self.supplier_code,
      self.item_type_name.try(:[],4..-1),
      self.brand_name,
      self.start_time.try(:strftime,'%d%b%y'),
      self.end_time.try(:strftime,'%d%b%y')
    ].compact.join('-')
    return code
  rescue
    return nil
  end

  def delete_promotion
    Ipos::Promotion
      .where('iddiskon ilike ?', "%_#{code}%")
      .destroy_all
  end

  private

  # filter should be filled at least one
  def filter_should_be_filled
    return true if [item,item_type,supplier,brand].any?
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
