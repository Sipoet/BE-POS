class PayslipLine < ApplicationRecord
  has_paper_trail ignore: [:id, :created_at, :updated_at]
  enum :group, {
    earning: 0,
    deduction: 1,
  }

  enum :payslip_type, {
    base_salary: 0, #gaji pokok
    incentive: 1, #tunjangan
    insurance: 2,
    debt: 3, #panjar
    commission: 4,
    tax: 5
  }

  enum :formula,{
    basic: 0,
    fulltime_schedule: 1,
    overtime_hour: 2,
    period_proportional: 3,
    annual_leave_cut: 4,
    sick_leave_cut: 5,
    hourly_daily: 6,
    fulltime_hour_per_day: 7,
    proportional_commission: 8,
  }

  validates :amount, presence: true, numericality:{greater_than: 0}
  validates :group, presence: true

  belongs_to :payslip, inverse_of: :payslip_lines
end
