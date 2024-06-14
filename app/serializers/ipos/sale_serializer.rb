class Ipos::SaleSerializer
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
              :jmldebit,
              :jmlkk,
              :jmlemoney,
              :payment_type,
              :ppn,
              :pajak,
              :bank_code

  has_many :sale_items, serializer: Ipos::SaleItemSerializer, if: Proc.new { |record, params| params[:include].include?('sale_items') rescue false } do |sale|
    sale.sale_items.order(nobaris: :asc)
  end

end
