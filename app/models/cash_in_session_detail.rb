class CashInSessionDetail < ApplicationRecord
  enum :status, {
    draft: 0,
    verified: 1
  }

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :begin_cash, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :cash_in, numericality: { greater_than_or_equal_to: 0 }, presence: true
  validates :status, presence: true
  validate :end_time_should_valid

  belongs_to :cashier, class_name: 'User', foreign_key: :user_id
  belongs_to :cashier_session, inverse_of: :cash_in_session_details

  def end_cash
    begin_cash + cash_in
  end

  private

  def end_time_should_valid
    return unless end_time.present? && end_time < start_time

    errors.add(:end_time, :greater_than, count: start_time.strftime('%d/%m/%y %H:%M'))
  end
end
