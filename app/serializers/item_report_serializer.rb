class ItemReportSerializer
  include JSONAPI::Serializer
  attributes :item_code, :item_name, :item_type_name, :supplier_code,
             :supplier_name, :brand_name, :item_type_desc,
             :gross_profit, :stock_left, :is_consignment


  %i{avg_buy_price sales_total purchase_total cogs sell_price percentage_sales}.each do |key|
    attribute key do |object|
      object.send(key).to_f.round(2)
    end
  end

  %i{number_of_sales number_of_purchase qty_return warehouse_stock store_stock item_out}.each do |key|
    attribute key do |object|
      object.send(key).to_i
    end
  end

  attribute :margin do |object|
     (object.sell_price / object.avg_buy_price -  1).round(3).to_f rescue nil
  end

  belongs_to :item, set_id: :item_code, id_method_name: :item_code
  belongs_to :supplier, set_id: :supplier_code, id_method_name: :supplier_code, serializer: Ipos::SupplierSerializer
  belongs_to :brand, set_id: :brand_name, id_method_name: :brand_name
  belongs_to :item_type, set_id: :item_type_name, id_method_name: :item_type_name

  attribute :last_purchase_date do |object|
    object.last_purchase_date.try(:iso8601)
  end

end
