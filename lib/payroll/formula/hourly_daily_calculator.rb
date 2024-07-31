class Payroll::Formula::HourlyDailyCalculator < Payroll::Formula::ApplicationCalculator
  # variable1 = amount get per month
  # variable2 = how many work hour include rest hour per day.
  #             if empty or zero, hours based scheduled how many

  def calculate
    total_work_day = 0
    min_work_calc = lambda{|detail| payroll_line.variable2.to_d}
    if payroll_line.variable2 == 0 || payroll_line.variable2.blank?
      min_work_calc = lambda{|detail| detail.is_late ? detail.scheduled_work_hours.to_d + 1 : detail.scheduled_work_hours.to_d}
    end
    attendance_summary.details.each do |detail|
      next if detail.work_hours == 0
      min_work = min_work_calc.call(detail)
      work_hours = [detail.work_hours,min_work].min.to_d
      total_work_day += (work_hours / min_work)
      Rails.logger.debug "#{@employee.name} #{detail.date} kerja #{work_hours} jam. min work #{min_work} total work days #{total_work_day}"
    end
    attendance_summary.total_full_work_days = total_work_day.round(1)
    ((attendance_summary.total_full_work_days.to_d / attendance_summary.total_day.to_d) * payroll_line.variable1.to_d).round(-2)
  end

end
