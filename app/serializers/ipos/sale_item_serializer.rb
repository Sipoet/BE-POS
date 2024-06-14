class Ipos::SaleItemSerializer
  include JSONAPI::Serializer
  attributes :kodeitem,
              :nobaris,
              :jumlah,
              :harga,
              :satuan,
              :subtotal,
              :potongan,
              :potongan2,
              :potongan3,
              :potongan4,
              :pajak,
              :total,
              :updated_at,
              :sistemhargajual,
              :tipepromo,
              :jmlgratis,
              :itempromo,
              :satuanpromo,
              :hppdasar

  belongs_to :item, set_id: :kodeitem, id_method_name: :kodeitem, serializer: ItemSerializer
end
