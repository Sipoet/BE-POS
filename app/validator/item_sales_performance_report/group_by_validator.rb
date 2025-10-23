class ItemSalesPerformanceReport::GroupByValidator < ApplicationModel

  attribute :group_type, :string
  attribute :group_period, :string
  attribute :value_type, :string
  attribute :start_date, :date
  attribute :end_date, :date
  attribute :separate_purchase_year, :boolean
  attribute :last_purchase_years, :array, of: :integer, default: []
  attribute :supplier_codes, :array, of: :string, default: []
  attribute :brand_names, :array, of: :string, default: []
  attribute :item_type_names, :array, of: :string, default: []
  attribute :item_codes, :array, of: :string, default: []

  validates :group_period, presence: true, inclusion: {in: ['hourly','daily','dow','weekly','monthly','yearly']}
  validates :value_type, presence: true, inclusion: {in: ['sales_total','sales_quantity','sales_discount_amount','sales_through_rate',
                                                          'gross_profit','cash_total','debit_total','credit_total','qris_total','online_total']}
  validates :group_type, presence: true, inclusion: {in: ['supplier','brand','item_type','item','period']}
  validates :start_date, presence: true
  validates :end_date, presence: true

  validate :sales_through_rate_not_support_period

  def indicator_field
    case group_type
    when 'supplier'
      :supplier_code
    when 'brand'
      :brand_name
    when 'item_type'
      :item_type_name
    when 'item'
      :item_code
    when 'period'
      period_indicator_field
    else
      :date_pk
    end
  end

  def suppliers
    Ipos::Supplier.where(code: supplier_codes).index_by(&:code)
  end

  def brands
    Ipos::Brand.where(name: brand_names).index_by(&:name)
  end

  def item_types
    Ipos::ItemType.where(name: item_type_names).index_by(&:name)
  end

  def items
    Ipos::Item.where(code: item_codes).index_by(&:code)
  end

  def period_indicator_field
    case group_period
    when 'hourly'
      :sales_hour
    when 'dow'
      :sales_day_of_week
    when 'weekly'
      :sales_week
    when 'yearly'
      :sales_year
    else
      :date_pk
    end
  end

  private

  def sales_through_rate_not_support_period
    if group_type == 'period' && value_type == 'sales_through_rate'
      errors.add(:value_type,'kecepatan penjualan tidak bisa dipisah dalam periode')
      return false
    end
  end

end
