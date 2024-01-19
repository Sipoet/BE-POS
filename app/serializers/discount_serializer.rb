class DiscountSerializer
  include JSONAPI::Serializer
  attributes :item_code, :supplier_code, :brand_name, :item_type_name, :code, :start_time, :end_time, :weight
  [:discount1, :discount2,:discount3,:discount4].each do |key|
    attribute key do |object|
      object.send(key).to_f
    end
  end

  cache_options store: Rails.cache, namespace: 'jsonapi-serializer', expires_in: 1.hour
end
