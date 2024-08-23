class CashInSessionDetail < ApplicationRecord

  TABLE_HEADER = [
    datatable_column(self,:start_time, :datetime),
    datatable_column(self,:end_time, :datetime),
    datatable_column(self,:status, :decimal),
    datatable_column(self,:begin_cash, :decimal),
    datatable_column(self,:cash_in, :decimal),
    datatable_column(self,:end_cash, :decimal),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ]

  enum :status,{
    draft: 0,
    verified: 1,
  }

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :begin_cash, numericality: {greater_than_or_equal_to: 0}, presence: true
  validates :cash_in, numericality: {greater_than_or_equal_to: 0}, presence: true
  validates :status, presence: true
  validate :end_time_should_valid

  belongs_to :cashier, class_name: 'User', foreign_key: :user_id
  belongs_to :cashier_session, inverse_of: :cash_in_session_details

  def end_cash
    begin_cash + cash_in
  end

  private

  def end_time_should_valid
    if end_time.present? && end_time < start_time
      errors.add(:end_time,:greater_than, count: start_time.strftime('%d/%m/%y %H:%M'))
    end
  end
end
