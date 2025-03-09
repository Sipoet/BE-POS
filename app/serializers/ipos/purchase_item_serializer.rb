class Ipos::PurchaseItemSerializer
  include JSONAPI::Serializer
  include TextFormatter
  attributes :kodeitem,
            :nobaris,
            :jumlah,
            :jmlpesan,
            :harga,
            :satuan,
            :subtotal,
            :potongan,
            :potongan2,
            :potongan3,
            :potongan4,
            :pajak,
            :total,
            :kodeprod,
            :hppdasar,
            :item_type_name,
            :supplier_code,
            :brand_name,
            :notransaksi

  [:updated_at, :tglexp].each do |key|
    attribute key do |object|
      ipos_fix_date_timezone(object.send(key))
    end
  end
  belongs_to :item, set_id: :kodeitem, id_method_name: :kodeitem, serializer: Ipos::ItemSerializer
end
