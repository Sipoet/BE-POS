class PaymentMethodSerializer
  include JSONAPI::Serializer
  attributes :name, :payment_type, :provider
end
