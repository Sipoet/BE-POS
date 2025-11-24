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
             :hppdasar,
             :item_type_name,
             :supplier_code,
             :brand_name,
             :item_name,
             :notransaksi,
             :transaction_date

  attribute :sale_type do |object|
    case object.sale_type
    when 'KSR', 'JL'
      'paid'
    when 'KSRP'
      'pending'
    when 'RJ'
      'return'
    when 'IK'
      'item_out'
    end
  end

  belongs_to :item, set_id: :kodeitem, id_method_name: :kodeitem, serializer: Ipos::ItemSerializer
  belongs_to :sale, if: proc { |_record, _params| false }
end
