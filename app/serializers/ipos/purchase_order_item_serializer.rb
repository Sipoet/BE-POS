class Ipos::PurchaseOrderItemSerializer
  include JSONAPI::Serializer
  include TextFormatter
  attributes :kodeitem,
             :iddetail,
             :nobaris,
             :jumlah,
             :jmlterima,
             :harga,
             :sell_price,
             :satuan,
             :subtotal,
             :potongan,
             :pajak,
             :total,
             :kodeprod,
             :detinfo,
             :sistemhargajual,
             :jmlkonversi,
             :item_type_name,
             :supplier_code,
             :brand_name,
             :notransaksi

  %i[dateupd tglexp].each do |key|
    attribute key do |object|
      ipos_fix_date_timezone(object.send(key))
    end
  end

  belongs_to :item, set_id: :kodeitem, id_method_name: :kodeitem, serializer: Ipos::ItemSerializer
end
