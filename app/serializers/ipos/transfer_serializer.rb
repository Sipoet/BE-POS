class Ipos::TransferSerializer
  include JSONAPI::Serializer
  attributes  :notransaksi,
              :tanggal,
              :kantordari,
              :kantortujuan,
              :keterangan,
              :totalitem,
              :user1,
              :shiftkerja,
              :updated_at

  has_many :transfer_items, serializer: Ipos::TransferItemSerializer, if: Proc.new { |record, params| params[:include].include?('transfer_items') rescue false } do |transfer|
    transfer.transfer_items.order(nobaris: :asc)
  end
end
