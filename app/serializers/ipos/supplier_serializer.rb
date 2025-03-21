class Ipos::SupplierSerializer
  include JSONAPI::Serializer
  attributes :code, :name,:address,:contact,:email,:bank,:account,:account_register_name,
            :description,:city

  cache_options store: Rails.cache, namespace: 'supplier-serializer', expires_in: 1.hour
end
