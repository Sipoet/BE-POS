class Payroll::Formula::HourlyDailyCalculator < Payroll::Formula::ApplicationCalculator
  # variable1 = amount get per month
  # variable2 = how many work hour include rest hour per day

  def calculate
    total_work_day = 0
    attendance_summary.work_hours.each do |hour|
      total_work_day += [hour,payroll_line.variable2].min.to_d / payroll_line.variable2.to_d
    end
    attendance_summary.total_full_work_days = total_work_day.floor
    ((attendance_summary.total_full_work_days.to_d / attendance_summary.total_day.to_d) * payroll_line.variable1.to_d).round(-2)
  end

end
