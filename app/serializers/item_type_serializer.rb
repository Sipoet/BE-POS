class ItemTypeSerializer
  include JSONAPI::Serializer
  attributes :jenis, :ketjenis

  cache_options store: Rails.cache, namespace: 'item_type-serializer', expires_in: 1.hour
end
