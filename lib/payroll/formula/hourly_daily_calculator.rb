class Payroll::Formula::HourlyDailyCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    total_work_day = 0
    attendance_summary.work_hours.each do |hour|
      total_work_day += 1 if hour >= payroll_line.variable2
    end
    attendance_summary.total_full_work_days = total_work_day
    ((total_work_day.to_d / attendance_summary.total_day.to_d) * payroll_line.variable1.to_d).round(-2)
  end

end
