class SupplierSerializer
  include JSONAPI::Serializer
  attributes :kode, :nama

  cache_options store: Rails.cache, namespace: 'supplier-serializer', expires_in: 1.hour
end
