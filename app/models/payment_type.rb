class PaymentType < ApplicationRecord
  validates :name, presence: true

  after_update do |record|
    Cache.delete_by_namespace 'payment_type-serializer'
  end
end
