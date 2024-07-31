class PaymentProviderSerializer
  include JSONAPI::Serializer
  attributes :code, :name, :currency, :account_number, :account_register_name, :created_at, :updated_at
end
