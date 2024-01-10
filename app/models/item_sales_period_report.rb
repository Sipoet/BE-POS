class ItemSalesPeriodReport
  extend ActiveModel::Naming
  extend ActiveModel::Translation

  TABLE_HEADER = [
    :item_code,
    :item_name,
    :supplier_code,
    :item_type_name,
    :brand_name,
    :discount_percentage,
    :quantity,
    :subtotal,
    :discount_total,
    :sales_total
  ]
  attr_accessor :item_code,
                :item_name,
                :supplier_code,
                :item_type_name,
                :brand_name,
                :quantity,
                :sales_total,
                :discount_percentage,
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
  end

  def id
    @item_code
  end

  def discount_total
    subtotal - sales_total
  end
end
