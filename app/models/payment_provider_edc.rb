class PaymentProviderEdc < ApplicationRecord


  validates :merchant_id, presence: true
  validates :terminal_id, presence: true

  belongs_to :payment_provider, inverse_of: :payment_provider_edcs

end
