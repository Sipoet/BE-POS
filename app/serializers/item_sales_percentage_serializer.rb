class ItemSalesPercentageSerializer
  include JSONAPI::Serializer
  attributes :item_code, :item_name, :item_type, :supplier_code,
             :supplier_name, :brand, :percentage_sales, :item_type_desc

  %i{avg_buy_price sales_total purchase_total sell_price}.each do |key|
    attribute key do |object|
      object.send(key).to_f.round(2)
    end
  end

  %i{number_of_sales number_of_purchase warehouse_stock store_stock}.each do |key|
    attribute key do |object|
      object.send(key).to_i
    end
  end

    attribute :recent_purchase_date do |object|
      object.recent_purchase_date.try(:iso8601)
    end
end
