class DiscountItemSerializer
  include JSONAPI::Serializer
  attributes :item_code, :is_exclude

  belongs_to :item, set_id: :item_code, id_method_name: :item_code,serializer: Ipos::ItemSerializer
end
