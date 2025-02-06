class Ipos::TransferSerializer
  include JSONAPI::Serializer
  include TextFormatter
  attributes  :notransaksi,
              :kantordari,
              :kantortujuan,
              :keterangan,
              :totalitem,
              :user1,
              :shiftkerja,
              :updated_at

  attribute :tanggal do |object|
    ipos_fix_date_timezone(object.tanggal)
  end

  attribute :updated_at do |object|
    ipos_fix_date_timezone(object.updated_at)
  end

  has_many :transfer_items, serializer: Ipos::TransferItemSerializer, if: Proc.new { |record, params| params[:include].include?('transfer_items') rescue false } do |transfer|
    transfer.transfer_items.order(nobaris: :asc)
  end
end
