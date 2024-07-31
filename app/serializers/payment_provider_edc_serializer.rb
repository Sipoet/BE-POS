class PaymentProviderEdcSerializer
  include JSONAPI::Serializer
  attributes :merchant_id, :terminal_id
end
