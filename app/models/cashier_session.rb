class CashierSession < ApplicationRecord
  enum :status, {
    draft: 0,
    current_active: 1,
    verified: 2
  }

  validates :date, presence: true
  validates :total_in, presence: true
  validates :total_out, presence: true
  validates :status, presence: true

  has_many :cash_in_session_details, inverse_of: :cashier_session, dependent: :destroy
  has_many :cash_out_session_details, inverse_of: :cashier_session, dependent: :destroy
  has_many :edc_settlements, inverse_of: :cashier_session, dependent: :destroy

  accepts_nested_attributes_for :cash_in_session_details, :cash_out_session_details, :edc_settlements,
                                allow_destroy: true

  def self.today_session
    sep_hour = Setting.get('day_separator_at') || '07:00'
    sep_time = Time.zone.parse("#{Date.today.iso8601} #{sep_hour}")
    if DateTime.now >= sep_time
      CashierSession.find_by(date: Date.today)
    else
      CashierSession.find_by(date: Date.yesterday)
    end
  end

  def start_time
    cash_in_session_details.minimum(:start_time)
  end

  def end_time
    cash_in_session_details.maximum(:end_time)
  end
end
