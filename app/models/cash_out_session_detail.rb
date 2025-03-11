class CashOutSessionDetail < ApplicationRecord

  enum :status, {
    draft: 0,
    verified: 1,
    unauthorized: 2,
  }

  validates :amount, numericality:{greater_than: 0}, presence: true
  validates :status, presence: true
  validates :name, presence: true
  validates :date, presence: true

  belongs_to :cashier, class_name:'User', foreign_key: :user_id
  belongs_to :cashier_session, inverse_of: :cash_out_session_details
end
