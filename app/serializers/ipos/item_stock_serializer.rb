class Ipos::ItemStockSerializer
  include JSONAPI::Serializer
  attributes :item_code, :location_code, :quantity, :rack
end
