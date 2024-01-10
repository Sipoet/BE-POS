class ItemSalesPeriodReportSerializer
  include JSONAPI::Serializer
  attributes  :item_code,
              :item_name,
              :supplier_code,
              :item_type_name,
              :brand_name,
              :discount_percentage,
              :quantity,
              :subtotal,
              :discount_total,
              :sales_total

end
