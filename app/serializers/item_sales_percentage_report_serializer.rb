class ItemSalesPercentageReportSerializer
  include JSONAPI::Serializer
  attributes :item_code, :item_name, :item_type_name, :supplier_code,
             :supplier_name, :brand_name, :percentage_sales, :item_type_desc,
             :gross_profit
  attribute :brand do |obj|
    obj.brand_name
  end

  attribute :item_type do |obj|
    obj.item_type_name
  end

  %i{avg_buy_price sales_total purchase_total sell_price}.each do |key|
    attribute key do |object|
      object.send(key).to_f.round(2)
    end
  end

  %i{number_of_sales number_of_purchase warehouse_stock store_stock item_out}.each do |key|
    attribute key do |object|
      object.send(key).to_i
    end
  end

    attribute :recent_purchase_date do |object|
      object.recent_purchase_date.try(:iso8601)
    end
end
