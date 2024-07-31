class CashierSession < ApplicationRecord

  TABLE_HEADER = [
    datatable_column(self,:date, :date),
    datatable_column(self,:total_in, :decimal),
    datatable_column(self,:total_out, :decimal),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ]

  enum :status,{
    draft: 0,
    current_active: 1,
    verified: 2,
  }

  validates :start_time, presence: true
  validates :end_time, presence: true
  validates :total_cash_in, presence: true
  validates :total_cash_out, presence: true
  validates :total_debit, presence: true
  validates :total_credit, presence: true
  validates :total_qris, presence: true
  validates :total_emoney, presence: true
  validates :total_transfer, presence: true
  validates :total_other_in, presence: true
  validates :status, presence: true
  validate :end_time_should_valid

  has_many :cash_in_session_details, inverse_of: :cashier_session, dependent: :destroy
  has_many :cash_out_session_details, inverse_of: :cashier_session, dependent: :destroy
  has_many :edc_settlements, inverse_of: :cashier_session, dependent: :destroy

  accepts_nested_attributes_for :cash_in_session_details, :cash_out_session_details, :edc_settlements, allow_destroy: true
  scope :today, -> {where("? BETWEEN start_time AND end_time",DateTime.now)}
  private

  def end_time_should_valid
    if end_time.present? && end_time < start_time
      errors.add(:end_time,:greater_than, count: start_time.strftime('%d/%m/%y %H:%M'))
    end
  end
end
