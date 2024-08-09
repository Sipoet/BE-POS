require 'big_decimal.rb'
class Discount < ApplicationRecord
  has_paper_trail ignore:[:id, :created_at, :updated_at]
  TABLE_HEADER = [
    datatable_column(self,:code, :string),
    datatable_column(self,:supplier_code, :link, path:'suppliers',attribute_key: 'supplier.name'),
    datatable_column(self,:item_type_name, :link, path:'item_types',attribute_key: 'item_type.ketjenis'),
    datatable_column(self,:brand_name, :link, path:'brands',attribute_key: 'brand.merek'),
    datatable_column(self,:item_code, :link, path:'items',attribute_key: 'item.namaitem'),
    datatable_column(self,:blacklist_supplier_code, :link, path:'suppliers',attribute_key: 'blacklist_supplier.nama'),
    datatable_column(self,:blacklist_item_type_name, :link, path:'item_types',attribute_key: 'blacklist_item_type.ketjenis'),
    datatable_column(self,:blacklist_brand_name, :link, path:'brands',attribute_key: 'blacklist_brand.merek'),
    datatable_column(self,:calculation_type, :enum),
    datatable_column(self,:weight, :string),
    datatable_column(self,:discount1, :percentage),
    datatable_column(self,:discount2, :percentage),
    datatable_column(self,:discount3, :percentage),
    datatable_column(self,:discount4, :percentage),
    datatable_column(self,:discount_type, :enum),
    datatable_column(self,:start_time, :datetime),
    datatable_column(self,:end_time, :datetime),
    datatable_column(self,:week1, :boolean),
    datatable_column(self,:week2, :boolean),
    datatable_column(self,:week3, :boolean),
    datatable_column(self,:week4, :boolean),
    datatable_column(self,:week5, :boolean),
    datatable_column(self,:week6, :boolean),
    datatable_column(self,:week7, :boolean),
  ].freeze

  attr_readonly :code

  enum :calculation_type,{
    percentage: 0,
    nominal: 1
  }

  enum :discount_type,{
    period: 0,
    repeated_hour_on_period: 1,
    day_of_week: 2,
  }

  validates :code, presence: true, uniqueness: true
  validates :weight, presence: true, numericality:{greater_than: 0, integer: true}
  validates :discount1, presence: true, numericality:{greater_than_and_equal_to: 0, less_than: 100}, if: :percentage?
  validates :discount1, presence: true, numericality:{greater_than: 0}, if: :nominal?
  validates :discount2, presence: true, numericality:{greater_than_and_equal_to: 0, less_than: 100}
  validates :discount3, presence: true, numericality:{greater_than_and_equal_to: 0, less_than: 100}
  validates :discount4, presence: true, numericality:{greater_than_and_equal_to: 0, less_than: 100}
  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :calculation_type, presence: true

  has_many :discount_items, dependent: :destroy
  has_many :discount_suppliers, dependent: :destroy
  has_many :discount_brands, dependent: :destroy
  has_many :discount_item_types, dependent: :destroy
  has_many :promotions, class_name: 'Ipos::Promotion', dependent: :destroy
  accepts_nested_attributes_for :discount_items, :discount_suppliers,:discount_brands,:discount_item_types, allow_destroy: true

  belongs_to :item, optional: true, foreign_key: :item_code, primary_key: :kodeitem, class_name:'Ipos::Item'
  belongs_to :item_type, optional: true, foreign_key: :item_type_name, primary_key: :jenis, class_name:'Ipos::ItemType'
  belongs_to :brand, optional: true, foreign_key: :brand_name, primary_key: :merek, class_name:'Ipos::Brand'
  belongs_to :supplier, optional: true, foreign_key: :supplier_code, primary_key: :kode, class_name:'Ipos::Supplier'

  belongs_to :blacklist_item_type, optional: true, foreign_key: :item_type_name, primary_key: :jenis, class_name:'Ipos::ItemType'
  belongs_to :blacklist_brand, optional: true, foreign_key: :brand_name, primary_key: :merek, class_name:'Ipos::Brand'
  belongs_to :blacklist_supplier, optional: true, foreign_key: :supplier_code, primary_key: :kode, class_name:'Ipos::Supplier'

  validate :range_time_should_valid
  validate :filter_should_be_filled

  scope :active_today, ->{where(start_time: ..(Time.now),end_time: (Time.now)..)}

  def generate_code
    self.code = [
      self.discount_items.first.try(:item_code),
      self.discount_suppliers.first.try(:supplier_code),
      self.discount_item_types.first.try(:item_type_name),
      self.discount_brands.first.try(:brand_name),
      self.start_time.try(:strftime,'%d%b%y'),
      self.end_time.try(:strftime,'%d%b%y')
    ].compact.join('-')
    return code
  rescue
    return nil
  end

  def delete_promotion
    promotions.destroy_all
  end

  private

  # filter should be filled at least one
  def filter_should_be_filled
    return true if [item,discount_items,item_type,supplier,brand].any?
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
