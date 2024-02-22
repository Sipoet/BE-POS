class Payroll::Formula::PeriodProportionalCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    ((attendance_summary.work_days / attendance_summary.total_day) * payroll_line.variable1).round
  end

end
