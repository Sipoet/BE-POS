require 'big_decimal'
class Discount < ApplicationRecord
  has_paper_trail ignore: %i[id created_at updated_at]

  enum :calculation_type, {
    percentage: 0,
    nominal: 1,
    special_price: 2
  }

  enum :discount_type, {
    period: 0,
    repeated_hour_on_period: 1,
    day_of_week: 2
  }

  validates :code, presence: true, uniqueness: true
  validates :weight, presence: true, numericality: { greater_than: 0, integer: true }
  validates :discount1, presence: true, numericality: { greater_than_and_equal_to: 0, less_than: 100 }, if: :percentage?
  validates :discount1, presence: true, numericality: { greater_than: 0 }, if: :nominal?
  validates :discount2, presence: true, numericality: { greater_than_and_equal_to: 0, less_than: 100 }
  validates :discount3, presence: true, numericality: { greater_than_and_equal_to: 0, less_than: 100 }
  validates :discount4, presence: true, numericality: { greater_than_and_equal_to: 0, less_than: 100 }
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :calculation_type, presence: true

  has_many :discount_filters, dependent: :destroy
  has_many :promotions, class_name: 'Ipos::Promotion', dependent: :destroy
  accepts_nested_attributes_for :discount_filters,
                                allow_destroy: true

  belongs_to :item, optional: true, foreign_key: :item_code, primary_key: :kodeitem, class_name: 'Ipos::Item'
  belongs_to :item_type, optional: true, foreign_key: :item_type_name, primary_key: :jenis, class_name: 'Ipos::ItemType'
  belongs_to :brand, optional: true, foreign_key: :brand_name, primary_key: :merek, class_name: 'Ipos::Brand'
  belongs_to :supplier, optional: true, foreign_key: :supplier_code, primary_key: :kode, class_name: 'Ipos::Supplier'

  belongs_to :blacklist_item_type, optional: true, foreign_key: :item_type_name, primary_key: :jenis, class_name: 'Ipos::ItemType'
  belongs_to :blacklist_brand, optional: true, foreign_key: :brand_name, primary_key: :merek, class_name: 'Ipos::Brand'
  belongs_to :blacklist_supplier, optional: true, foreign_key: :supplier_code, primary_key: :kode, class_name: 'Ipos::Supplier'
  belongs_to :customer_group, optional: true, foreign_key: :customer_group_code, primary_key: :kgrup, class_name: 'Ipos::CustomerGroup'
  validate :range_time_should_valid
  validate :filter_should_be_filled

  scope :active_today, -> { where(start_time: ..(Time.now), end_time: (Time.now)..) }

  def generate_code
    self.code = [
      discount_items.first.try(:value),
      discount_suppliers.first.try(:value),
      discount_item_types.first.try(:value),
      discount_brands.first.try(:value),
      start_time.try(:strftime, '%d%b%y'),
      end_time.try(:strftime, '%d%b%y')
    ].compact.join('-')
    code
  rescue StandardError
    nil
  end

  def delete_promotion
    promotions.destroy_all
  end

  def discount_items
    group_filter['item'] || []
  end

  def discount_brands
    group_filter['brand'] || []
  end

  def discount_suppliers
    group_filter['supplier'] || []
  end

  def discount_item_types
    group_filter['item_type'] || []
  end

  def reload
    @group_filter = nil
    super
  end

  private

  def group_filter
    @group_filter ||= discount_filters.group_by(&:filter_key)
  end

  # filter should be filled at least one
  def filter_should_be_filled
    return true if [item, discount_items, item_type, supplier, brand].any?

    errors.add(:base,
               "Salah satu filter(#{Discount.human_attribute_name(:item_code)}, #{Discount.human_attribute_name(:item_type)}, #{Discount.human_attribute_name(:supplier_code)}, #{Discount.human_attribute_name(:brand_name)}) harus diisi")
  end

  def range_time_should_valid
    return unless [start_time, end_time].all?

    return unless start_time > end_time

    errors.add(:start_time, :greater_than, count: end_time)
    errors.add(:end_time, :less_than, count: start_time)
  end
end
