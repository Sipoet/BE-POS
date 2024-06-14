class Ipos::PurchaseItemSerializer
  include JSONAPI::Serializer
  attributes :kodeitem,
            :nobaris,
            :jumlah,
            :jmlpesan,
            :harga,
            :sell_price,
            :satuan,
            :subtotal,
            :potongan,
            :potongan2,
            :potongan3,
            :potongan4,
            :pajak,
            :total,
            :tglexp,
            :kodeprod,
            :updated_at,
            :hppdasar

  belongs_to :item, set_id: :kodeitem, id_method_name: :kodeitem, serializer: ItemSerializer
end
