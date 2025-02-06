class Ipos::SaleSerializer
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
              :jmldebit,
              :jmlkk,
              :jmlemoney,
              :payment_type,
              :ppn,
              :pajak,
              :bank_code

  attribute :tanggal do |object|
    ipos_fix_date_timezone(object.tanggal)
  end

  has_many :sale_items, serializer: Ipos::SaleItemSerializer, if: Proc.new { |record, params| params[:include].include?('sale_items') rescue false } do |sale|
    sale.sale_items.order(nobaris: :asc)
  end

end
