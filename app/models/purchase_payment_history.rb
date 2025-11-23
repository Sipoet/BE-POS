class PurchasePaymentHistory < ApplicationRecord
  self.table_name = 'purchase_payment_histories'

  belongs_to :supplier, class_name: 'Ipos::Supplier', foreign_key: :supplier_code, primary_key: :kode
  belongs_to :purchase, class_name: 'Ipos::Purchase', optional: true, foreign_key: :purchase_code,
                        primary_key: :notransaksi
  belongs_to :purchase_order, class_name: 'Ipos::PurchaseOrder', optional: true, foreign_key: :purchase_order_code,
                              primary_key: :notransaksi

  def readonly?
    true
  end
end
