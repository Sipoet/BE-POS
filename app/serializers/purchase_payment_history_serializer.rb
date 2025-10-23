class PurchasePaymentHistorySerializer
  include JSONAPI::Serializer
  include TextFormatter

  attributes :code, :description, :grand_total, :discount_amount, :debt_total,
             :payment_amount, :supplier_code, :purchase_code, :purchase_order_code,
             :payment_account_code, :debt_left

  %i[transaction_at invoiced_at stock_arrived_at].each do |key|
    attribute key do |object|
      ipos_fix_date_timezone(object.send(key))&.iso8601
    end
  end

  belongs_to :payment_account, set_id: :payment_account_code, id_method_name: :payment_account_code, serializer: Ipos::AccountSerializer
  belongs_to :supplier, set_id: :supplier_code, id_method_name: :supplier_code, serializer: Ipos::SupplierSerializer
  belongs_to :purchase, set_id: :purchase_code, id_method_name: :purchase_code, serializer: Ipos::PurchaseSerializer
  belongs_to :purchase_order, set_id: :purchase_order_code, id_method_name: :purchase_order_code, serializer: Ipos::PurchaseOrderSerializer
end
