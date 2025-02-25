class ItemSerializer
  include JSONAPI::Serializer
  attributes :kodeitem, :namaitem, :supplier1, :jenis, :merek,:hargapokok,:hargajual1

  belongs_to :supplier, set_id: :supplier1, id_method_name: :supplier1, serializer: Ipos::SupplierSerializer
  belongs_to :brand, set_id: :merek, id_method_name: :merek
  belongs_to :item_type, set_id: :jenis, id_method_name: :jenis

  has_many :discount_rules, if: Proc.new { |record, params| params[:include].include?('discount_rules') rescue false }
  # cache_options store: Rails.cache, namespace: 'item-serializer', expires_in: 1.hour
end
