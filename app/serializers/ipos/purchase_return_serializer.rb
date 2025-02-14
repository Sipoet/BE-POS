class Ipos::PurchaseReturnSerializer
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
              :ppn,
              :pajak,
              :kodesupel



  attribute :tanggal do |object|
    ipos_fix_date_timezone(object.tanggal)
  end

  belongs_to :supplier, set_id: :kodesupel, id_method_name: :kodesupel, serializer: Ipos::SupplierSerializer, if: Proc.new { |record, params| params[:include].include?('supplier') rescue false }

  has_many :purchase_return_items, serializer: Ipos::PurchaseReturnItemSerializer, if: Proc.new { |record, params| params[:include].include?('purchase_return_items') rescue false } do |purchase_return|
    purchase_return.purchase_return_items.order(nobaris: :asc)
  end

end
