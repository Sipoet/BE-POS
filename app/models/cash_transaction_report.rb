# frozen_string_literal: true

class CashTransactionReport < ApplicationRecord
  self.table_name = 'cash_transaction_reports'
  belongs_to :payment_account, class_name: 'Ipos::Account', foreign_key: :payment_account_code, primary_key: :kodeacc
  belongs_to :detail_account, class_name: 'Ipos::Account', foreign_key: :detail_account_code, primary_key: :kodeacc

  def readonly?
    true
  end
end
