class Ipos::PurchaseItemSerializer
  include JSONAPI::Serializer
  include TextFormatter
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

  attribute :stock_left do |object|
    object.item_report&.stock_left
  end

  attribute :warehouse_stock do |object|
    object.item_report&.warehouse_stock
  end
  attribute :store_stock do |object|
    object.item_report&.store_stock
  end

  attribute :number_of_sales do |object|
    object.item_report&.number_of_sales
  end

  belongs_to :item, set_id: :kodeitem, id_method_name: :kodeitem, serializer: Ipos::ItemSerializer
end
