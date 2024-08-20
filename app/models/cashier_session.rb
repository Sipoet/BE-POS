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

  validates :date, presence: true
  validates :total_in, presence: true
  validates :total_out, presence: true
  validates :status, presence: true


  has_many :cash_in_session_details, inverse_of: :cashier_session, dependent: :destroy
  has_many :cash_out_session_details, inverse_of: :cashier_session, dependent: :destroy
  has_many :edc_settlements, inverse_of: :cashier_session, dependent: :destroy

  accepts_nested_attributes_for :cash_in_session_details, :cash_out_session_details, :edc_settlements, allow_destroy: true
  scope :today, -> {where(date: Date.today)}

  def start_time
    cash_in_session_details.minimum(:start_time)
  end

  def end_time
    cash_in_session_details.maximum(:end_time)
  end

end
