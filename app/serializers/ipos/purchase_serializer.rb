class Ipos::PurchaseSerializer
  include JSONAPI::Serializer
  attributes :notransaksi,
              :user1,
              :tanggal,
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
              :pajak

  has_many :purchase_items, serializer: Ipos::PurchaseItemSerializer, if: Proc.new { |record, params| params[:include].include?('purchase_items') rescue false } do |purchase|
    purchase.purchase_items.order(nobaris: :asc)
  end

end
