class Payroll::Formula::HourlyDailyCalculator < Payroll::Formula::ApplicationCalculator
  # variable1 = amount get per month
  # variable2 = how many work hour include rest hour per day

  def calculate
    total_work_day = 0
    attendance_summary.details.each do |detail|
      total_work_day += [detail.work_hours,detail.scheduled_work_hours].min.to_d / payroll_line.variable2.to_d
    end
    attendance_summary.total_full_work_days = total_work_day.round(1)
    ((attendance_summary.total_full_work_days.to_d / attendance_summary.total_day.to_d) * payroll_line.variable1.to_d).round(-2)
  end

end
