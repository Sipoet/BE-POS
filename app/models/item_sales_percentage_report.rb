class ItemSalesPercentageReport < ApplicationRecord
  self.table_name = 'item_sales_percentage_reports'
  self.primary_key = 'item_code'
  TABLE_HEADER = [
    datatable_column(self,:item_code, :string),
    datatable_column(self,:item_name, :string),
    datatable_column(self,:item_type_name, :string),
    datatable_column(self,:item_type_desc, :string),
    datatable_column(self,:supplier_code, :string),
    datatable_column(self,:supplier_name, :string),
    datatable_column(self,:brand_name, :string),
    datatable_column(self,:recent_purchase_date, :date),
    datatable_column(self,:warehouse_stock, :integer),
    datatable_column(self,:store_stock, :integer),
    datatable_column(self,:item_out, :integer),
    datatable_column(self,:avg_buy_price, :decimal),
    datatable_column(self,:number_of_purchase, :integer),
    datatable_column(self,:purchase_total, :decimal),
    datatable_column(self,:sell_price, :decimal),
    datatable_column(self,:number_of_sales, :integer),
    datatable_column(self,:sales_total, :decimal),
    datatable_column(self,:gross_profit, :decimal),
    datatable_column(self,:percentage_sales , :percentage)
  ].freeze

  def id
    item_code
  end

  def percentage_sales
    return 0.0 if number_of_purchase == 0
    return (number_of_sales.to_f / number_of_purchase.to_f * 100).round(2)

  end
end
