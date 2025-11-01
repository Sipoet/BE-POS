class Ipos::ItemSerializer
  include JSONAPI::Serializer
  include TextFormatter
  attributes :code, :name, :sell_price, :cogs, :code, :name, :supplier_code, :brand_name,
             :item_type_name, :uom, :description

  belongs_to :supplier, set_id: :supplier1, id_method_name: :supplier1, serializer: Ipos::SupplierSerializer
  belongs_to :brand, set_id: :merek, id_method_name: :merek
  belongs_to :item_type, set_id: :jenis, id_method_name: :jenis

  attribute :barcode do |object|
    object.code
  end

  attribute :updated_at do |object|
    ipos_fix_date_timezone(object.updated_at)
  end
  cache_options store: Rails.cache, namespace: 'item-serializer', expires_in: 1.hour
end
