class DiscountItemSerializer
  include JSONAPI::Serializer
  attributes :item_code

  attribute :is_exclude do
    false
  end

  belongs_to :item, set_id: :item_code, id_method_name: :item_code
end
