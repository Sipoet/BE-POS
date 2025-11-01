class ItemSalesPeriodReport < ApplicationModel
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
                :discount_amount,
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
    @discount_percentage = row['discount_percentage'].to_f / 100
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
