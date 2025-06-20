class Ipos::ConsignmentInSerializer
  include JSONAPI::Serializer
  include TextFormatter
  attributes :notransaksi,
              :user1,
              :keterangan,
              :totalitem,
              :subtotal,
              :totalakhir,
              :potnomfaktur,
              :biayalain,
              :jmltunai,
              :jmlkredit,
              :kantortujuan,
              :kodekantor,
              :jmldeposit,
              :notrsorder,
              :ppn,
              :pajak,
              :kodesupel

  attribute :tanggal do |object|
    ipos_fix_date_timezone(object.tanggal)
  end

  belongs_to :supplier, set_id: :kodesupel, id_method_name: :kodesupel, serializer: Ipos::SupplierSerializer, if: Proc.new { |record, params| params[:include].include?('supplier') rescue false }
  belongs_to :consignment_in_order, set_id: :notrsorder, id_method_name: :notrsorder, serializer: Ipos::ConsignmentInOrderSerializer, if: Proc.new { |record, params| params[:include].include?('consignment_in_order') rescue false }
  has_many :purchase_items, serializer: Ipos::PurchaseItemSerializer, if: Proc.new { |record, params| params[:include].include?('purchase_items') rescue false } do |consignment_in|
    consignment_in.purchase_items.includes(:item).order(nobaris: :asc)
  end

  attribute :note_date do |object|
    ipos_fix_date_timezone(object.consignment_in_order&.tanggal)
  end
end
