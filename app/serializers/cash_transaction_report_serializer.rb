class CashTransactionReportSerializer
  include JSONAPI::Serializer
  attributes :code, :payment_amount, :transaction_type, :updated_at, :detail_account_code, :description,
             :payment_account_code, :transaction_at

  belongs_to :payment_account, serializer: Ipos::AccountSerializer, set_id: :payment_account_code,
                               id_method_name: :payment_account_code
  belongs_to :detail_account, serializer: Ipos::AccountSerializer, set_id: :detail_account_code,
                              id_method_name: :detail_account_code
end
