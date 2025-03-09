class Ipos::BrandSerializer
  include JSONAPI::Serializer
  attributes :merek, :ketmerek
  cache_options store: Rails.cache, namespace: 'brand-serializer', expires_in: 1.hour
end
