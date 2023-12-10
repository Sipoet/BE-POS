class ItemSalesPercentageReport < ApplicationRecord
  self.table_name = 'item_sales_percentage_reports'
  self.primary_key = 'item_code'
  TABLE_HEADER = [
    :item_code,
    :item_name,
    :item_type,
    :supplier,
    :brand,
    :avg_buy_price,
    :number_of_purchase,
    :purchase_total,
    :sell_price,
    :number_of_sales,
    :sales_total,
    :percentage_sales
  ].freeze

  def id
    item_code
  end

  def percentage_sales
    return '0%' if number_of_purchase == 0
    value = (number_of_sales.to_f / number_of_purchase.to_f * 100).round(2)
    "#{value}%"
  end
end
