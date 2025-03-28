class PaymentProvider < ApplicationRecord


  enum :status, {
    inactive: 0,
    active: 1
  }

  validates :bank_or_provider, presence: true
  validates :name, presence: true
  validates :currency, presence: true
  validates :account_number, presence: true
  validates :account_register_name, presence: true
  validate :valid_swift_code

  has_many :payment_provider_edcs, dependent: :destroy, inverse_of: :payment_provider
  accepts_nested_attributes_for :payment_provider_edcs
  private

  def valid_swift_code
    return if swift_code.blank?
    return if swift_code.strip.match?(/^[A-Z]{6}[A-Z0-9]{2}([A-Z0-9]{3})?$/i)
    errors.add(:swift_code, :invalid)
  end
end
