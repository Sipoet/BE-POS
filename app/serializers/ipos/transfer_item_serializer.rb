class Ipos::TransferItemSerializer
  include JSONAPI::Serializer
  attributes :kodeitem,
              :jumlah,
              :cogs,
              :sell_price,
              :satuan,
              :tglexp,
              :kodeprod,
              :jmlkonversi,
              :detinfo,
              :nobaris,
              :updated_at,
              :notransaksi,
              :item_type_name,
              :supplier_code,
              :brand_name

  belongs_to :item, set_id: :kodeitem, id_method_name: :kodeitem, serializer: ItemSerializer
end
