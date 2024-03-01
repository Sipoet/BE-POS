class ItemSerializer
  include JSONAPI::Serializer
  attributes :kodeitem, :namaitem, :supplier1, :jenis, :merek

  belongs_to :supplier, set_id: :supplier1, id_method_name: :supplier1
  belongs_to :brand, set_id: :merek, id_method_name: :merek
  belongs_to :item_type, set_id: :jenis, id_method_name: :jenis
end
