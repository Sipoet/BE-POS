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
             :notransaksi,
             :purchase_type

  %i[updated_at tglexp transaction_date].each do |key|
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

  belongs_to :item, set_id: :kodeitem, id_method_name: :kodeitem, serializer: Ipos::ItemSerializer, if: proc { |record, params|
    begin
      params[:include].include?('item') || params[:include].include?('purchase_items.item')
    rescue StandardError
      false
    end
  }

  belongs_to :purchase, set_id: :notransaksi, id_method_name: :notransaksi, serializer: Ipos::PurchaseSerializer, if: proc { |record, params|
    begin
      params[:include].include?('purchase') && record.purchase.is_a?(Ipos::Purchase)
    rescue StandardError
      false
    end
  }

  belongs_to :purchase_return, set_id: :notransaksi, id_method_name: :notransaksi, serializer: Ipos::PurchaseReturnSerializer, if: proc { |record, params|
    begin
      params[:include].include?('purchase') && record.purchase.is_a?(Ipos::PurchaseReturn)
    rescue StandardError
      false
    end
  }

  belongs_to :consignment_in, set_id: :notransaksi, id_method_name: :notransaksi, serializer: Ipos::ConsignmentInSerializer, if: proc { |record, params|
    begin
      params[:include].include?('purchase') && record.purchase.is_a?(Ipos::ConsignmentIn)
    rescue StandardError
      false
    end
  }
end
