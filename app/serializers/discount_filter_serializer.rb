class DiscountFilterSerializer
  include JSONAPI::Serializer
  attributes :filter_key, :is_exclude, :value
end
