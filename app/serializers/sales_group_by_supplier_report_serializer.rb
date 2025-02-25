class SalesGroupBySupplierReportSerializer
  include JSONAPI::Serializer
  attributes  :supplier_code,
              :supplier_name,
              :item_type_name,
              :brand_name,
              :sales_total,
              :purchase_total,
              :gross_profit
  [
    :number_of_purchase,
    :number_of_sales,
    :stock_left
  ].each do |key|
    attribute key do |obj|
      obj.send(key).to_i
    end
  end


  attribute :sales_percentage do |obj|
    obj.sales_percentage.to_f
  end

  attribute :last_purchase_date do |obj|
    obj.last_purchase_date.try(:iso8601)
  end

end
