class CashOutSessionDetail < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:date,:datetime),
    datatable_column(self,:user_id, :link,path: 'users', attribute_key:'users.code'),
    datatable_column(self,:name, :string),
    datatable_column(self,:status, :enum),
    datatable_column(self,:amount, :money),
    datatable_column(self,:description, :string),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ]
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
