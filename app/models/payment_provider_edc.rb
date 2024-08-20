class PaymentProviderEdc < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:payment_provider_id, :integer),
    datatable_column(self,:terminal_id, :string),
    datatable_column(self,:merchant_id, :string),
  ]

  validates :merchant_id, presence: true
  validates :terminal_id, presence: true

  belongs_to :payment_provider, inverse_of: :payment_provider_edcs

end
