class SalesGroupBySupplierReport < ApplicationModel

  TABLE_HEADER = [
    datatable_column(self, :supplier_code, :string),
    datatable_column(self, :item_type_name, :string),
    datatable_column(self, :brand_name, :string),
    datatable_column(self, :number_of_purchase, :integer),
    datatable_column(self, :number_of_sales, :integer),
    datatable_column(self, :stock_left, :integer),
    datatable_column(self, :sales_percentage, :percentage),
].freeze

  attr_accessor :supplier_code,
                :item_type_name,
                :number_of_purchase,
                :number_of_sales,
                :brand_name
  def initialize(row)
    @supplier_code = row['supplier_code']
    @item_type_name = row['item_type_name']
    @number_of_purchase = row['number_of_purchase']
    @number_of_sales = row['number_of_sales']
    @brand_name = row['brand_name']
  end

  def id
    @supplier_code
  end

  def stock_left
    @number_of_purchase - @number_of_sales
  end

  def sales_percentage
    return 0 if number_of_purchase == 0
    (number_of_sales/number_of_purchase * 100).round(2)
  end
end
