class ItemSalesPercentageSerializer
  include JSONAPI::Serializer
  attributes :item_code, :item_name, :item_type, :supplier, :brand, :percentage_sales
  attribute :sell_price do |object|
    object.sell_price.to_f
  end
  attribute :avg_buy_price do |object|
    object.avg_buy_price.to_f.round(2)
  end
  attribute :number_of_sales do |object|
    object.number_of_sales.to_i
  end
  attribute :sales_total do |object|
    object.sales_total.to_f
  end
  attribute :number_of_purchase do |object|
    object.number_of_purchase.to_i
  end
  attribute :purchase_total do |object|
    object.purchase_total.to_f
  end
end
