class PaymentMethod < ApplicationRecord
  has_paper_trail ignore:[:id, :created_at, :updated_at]

  belongs_to :payment_provider
  belongs_to :payment_type

end
