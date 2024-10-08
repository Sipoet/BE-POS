class SalesGroupBySupplierReport < ApplicationModel

  TABLE_HEADER = [
    datatable_column(self, :supplier_name, :string),
    datatable_column(self, :item_type_name, :string),
    datatable_column(self, :brand_name, :string),
    datatable_column(self, :number_of_purchase, :integer),
    datatable_column(self, :number_of_sales, :integer),
    datatable_column(self, :stock_left, :integer),
    datatable_column(self, :purchase_total, :money),
    datatable_column(self, :sales_total, :money),
    datatable_column(self, :gross_profit, :money),
    datatable_column(self, :sales_percentage, :percentage)
].freeze

  attr_accessor :supplier_code,
                :supplier_name,
                :item_type_name,
                :number_of_purchase,
                :number_of_sales,
                :sales_total,
                :purchase_total,
                :gross_profit,
                :brand_name
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
  end

  def id
    "#{@supplier_code}-#{@item_type_name}-#{@brand_name}"
  end

  def stock_left
    @number_of_purchase - @number_of_sales
  end

  def sales_percentage
    return 0 if number_of_purchase == 0
    (number_of_sales.to_d/number_of_purchase.to_d * 100).round(2)
  end
end
