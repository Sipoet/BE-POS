class Payroll::Formula::PeriodProportionalCalculator < Payroll::Formula::ApplicationCalculator

  # variable1 amount if full period presence

  def calculate
    ((attendance_summary.work_days.to_d / attendance_summary.total_day.to_d) * payroll_line.variable1.to_d).round(-2)
  end

end
