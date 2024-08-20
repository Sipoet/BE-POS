class PaymentTypeSerializer
  include JSONAPI::Serializer
  attributes :name, :created_at, :updated_at

  cache_options store: Rails.cache, namespace: 'payment_type-serializer', expires_in: 1.hour
end
