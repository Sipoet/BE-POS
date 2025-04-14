class SalesGroupBySupplierReport < ApplicationModel

  attr_accessor :supplier_code,
                :supplier_name,
                :item_type_name,
                :number_of_purchase,
                :number_of_sales,
                :sales_total,
                :purchase_total,
                :gross_profit,
                :brand_name,
                :last_purchase_date
  def initialize(row)
    @supplier_code = row['supplier_code']
    @supplier_name = row['supplier_name']
    @item_type_name = row['item_type_name']
    @number_of_purchase = row['number_of_purchase'].to_i
    @number_of_sales = row['number_of_sales'].to_i
    @brand_name = row['brand_name']
    @purchase_total = row['purchase_total']
    @sales_total = row['sales_total']
    @gross_profit = row['gross_profit']
    @last_purchase_date = row['last_purchase_date']&.utc&.to_date
  end

  def id
    "#{@supplier_code}-#{@item_type_name}-#{@brand_name}"
  end

  def stock_left
    @number_of_purchase - @number_of_sales
  end

  def sales_percentage
    return 0 if number_of_purchase == 0
    (number_of_sales.to_d/number_of_purchase.to_d).round(2)
  end
end
