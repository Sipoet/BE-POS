class Payroll::Formula::PeriodProportionalCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    total = attendance_summary.work_days.to_d + attendance_summary.paid_time_off.to_d
    return payroll_line.variable1 if total >= attendance_summary.total_day
    ((attendance_summary.work_days.to_d / attendance_summary.total_day.to_d) * payroll_line.variable1).round
  end

end
