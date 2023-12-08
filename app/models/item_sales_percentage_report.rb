class ItemSalesPercentageReport
  TABLE_HEADER = [
    :item_code,
    :item_name,
    :item_type,
    :supplier,
    :brand,
    :sell_price,
    :avg_buy_price,
    :number_of_sales,
    :sales_total,
    :number_of_purchase,
    :purchase_total,
    :percentage_sales
  ].freeze

  attr_accessor :item_code,
                :item_name,
                :item_type,
                :supplier,
                :brand,
                :sell_price,
                :avg_buy_price,
                :number_of_sales,
                :sales_total,
                :number_of_purchase,
                :purchase_total

  alias_method  :id, :item_code

  def initialize(opt = {})
    options = opt.symbolize_keys
    @item_code = options[:item_code]
    @item_name = options[:item_name]
    @item_type = options[:item_type]
    @supplier = options[:supplier]
    @brand = options[:brand]
    @sell_price = options[:sell_price]
    @avg_buy_price = options[:avg_buy_price] || 0
    @number_of_sales = options[:number_of_sales]
    @sales_total = options[:sales_total]
    @number_of_purchase = options[:number_of_purchase]
    @purchase_total = options[:purchase_total]
  end

  def percentage_sales
    return '0%' if number_of_purchase == 0
    value = (number_of_sales.to_f / number_of_purchase.to_f * 100).round(2)
    "#{value}%"
  end
end
