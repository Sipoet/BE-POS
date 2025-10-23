module PayrollFormula
  extend ActiveSupport::Concern

  PAYROLL_FORMULA_LIST = {
    basic: 0,
    fulltime_schedule: 1,
    overtime_hour: 2,
    period_proportional: 3,
    annual_leave_cut: 4,
    sick_leave_cut: 5,
    hourly_daily: 6,
    fulltime_hour_per_day: 7,
    proportional_commission: 8,
    cashier_commission: 9
  }.freeze
end
