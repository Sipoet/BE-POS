class ItemSalesPeriodReport < ApplicationModel

  TABLE_HEADER = [
    datatable_column(self,:item_code, :string),
    datatable_column(self,:item_name, :string),
    datatable_column(self,:supplier_code, :string),
    datatable_column(self,:item_type_name, :string),
    datatable_column(self,:brand_name, :string),
    datatable_column(self,:is_consignment, :boolean),
    datatable_column(self,:discount_percentage, :decimal),
    datatable_column(self,:buy_price, :money),
    datatable_column(self,:sell_price, :money),
    datatable_column(self,:quantity, :integer),
    datatable_column(self,:subtotal, :money),
    datatable_column(self,:discount_total, :money),
    datatable_column(self,:sales_total, :money)
  ].freeze

  attr_accessor :item_code,
                :item_name,
                :supplier_code,
                :item_type_name,
                :brand_name,
                :buy_price,
                :sell_price,
                :quantity,
                :sales_total,
                :discount_percentage,
                :is_consignment,
                :subtotal
  def initialize(row)
    @item_code = row['item_code']
    @item_name = row['item_name']
    @supplier_code = row['supplier_code']
    @item_type_name = row['item_type_name']
    @brand_name = row['brand_name']
    @quantity = row['quantity'].to_i
    @sales_total = row['sales_total'].to_f
    @discount_percentage = row['discount_percentage'].to_f
    @subtotal = row['subtotal'].to_f
    @buy_price = row['buy_price'].to_f
    @sell_price = row['sell_price'].to_f
    @is_consignment = row['is_consignment']
  end

  def id
    @item_code
  end

  def discount_total
    subtotal - sales_total
  end
end
