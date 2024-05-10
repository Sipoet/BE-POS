class DiscountItemTypeSerializer
  include JSONAPI::Serializer
  attributes :item_type_name, :is_exclude

  belongs_to :item_type, set_id: :item_type_name, id_method_name: :item_type_name
end
