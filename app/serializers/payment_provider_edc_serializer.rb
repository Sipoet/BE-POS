class PaymentProviderEdcSerializer
  include JSONAPI::Serializer
  attributes :merchant_id, :terminal_id, :created_at, :updated_at
end
