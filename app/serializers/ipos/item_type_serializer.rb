class Ipos::ItemTypeSerializer
  include JSONAPI::Serializer
  attributes :name, :description

  cache_options store: Rails.cache, namespace: 'item_type-serializer', expires_in: 1.hour
end
