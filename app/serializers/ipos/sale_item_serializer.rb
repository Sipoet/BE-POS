class Ipos::SaleItemSerializer
  include JSONAPI::Serializer
  include TextFormatter
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
             :notransaksi

  %i[updated_at transaction_date].each do |key|
    attribute key do |object|
      ipos_fix_date_timezone(object.send(key))
    end
  end

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
  belongs_to :sale, set_id: :notransaksi, id_method_name: :notransaksi, if: proc { |_record, _params|
    begin
      params[:include].include?('sale')
    rescue StandardError
      false
    end
  }
end
