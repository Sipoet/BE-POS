class Ipos::PurchaseOrderSerializer
  include JSONAPI::Serializer
  include TextFormatter
  attributes  :notransaksi,
              :kodekantor,
              :kantortujuan,
              :tipe,
              :jenis,
              :kodesupel,
              :kodesales,
              :matauang,
              :rate,
              :keterangan,
              :komisi1,
              :totalitem,
              :totalterima,
              :subtotal,
              :potfaktur,
              :pajak,
              :biayalain,
              :totalakhir,
              :biaya_msk_total,
              :user1,
              :potnomfaktur,
              :prpajak,
              :dppesanan,
              :dppesananbyr,
              :acc_dppesanan,
              :acc_dpkas,
              :ppn,
              :bc_trf_sts,
              :prpotfaktur,
              :acc_biaya_pot,
              :opsikirim


  [:tanggal, :tanggalkirim, :dateupd].each do |key|
    attribute key do |object|
      ipos_fix_date_timezone(object.send(key))
    end
  end

  belongs_to :supplier, set_id: :kodesupel, id_method_name: :kodesupel, serializer: Ipos::SupplierSerializer, if: Proc.new { |record, params| params[:include].include?('supplier') rescue false }

  has_many :purchase_order_items, serializer: Ipos::PurchaseOrderItemSerializer, if: Proc.new { |record, params| params[:include].include?('purchase_order_items') rescue false } do |purchase_order|
    purchase_order.purchase_order_items.order(nobaris: :asc)
  end

end
