class Payroll::Formula::FulltimeHourPerDayCalculator < Payroll::Formula::ApplicationCalculator

  # variable1 = total full amount when min full schedule day work
  # variable2 = how many work hour include rest hour per day
  # variable3 = how many deduction amount per day of absence after offset
  # variable4 = offset of whether known absence is okay
  # variable5 = offset of whether unknown absence is okay

  def calculate
    last_date = attendance_summary.details.last.date
    begin_date = employee.start_working_date
    return 0 if ((begin_date..last_date).to_a.length < 7 && attendance_summary.is_last_work)
    full_work_days = 0
    min_work_calc = lambda{|detail| payroll_line.variable2.to_d}
    if payroll_line.variable2 == 0 || payroll_line.variable2.blank?
      min_work_calc = lambda{|detail| detail.is_late ? detail.scheduled_work_hours.to_d + 1 : detail.scheduled_work_hours.to_d}
    end
    if attendance_summary.total_full_work_days == 0 || attendance_summary.total_full_work_days.nil?
      attendance_summary.details.each do |detail|
        next if detail.work_hours == 0
        min_work_hour = min_work_calc.call(detail)
        full_work_days += [detail.work_hours,min_work_hour].min.to_d / min_work_hour.to_d
      end
      attendance_summary.total_full_work_days = full_work_days.round(1)
    else
      full_work_days = attendance_summary.total_full_work_days
    end
    total = payroll_line.variable1
    if attendance_summary.is_first_work || attendance_summary.is_last_work
      total *= full_work_days.to_d / attendance_summary.total_day.to_d
    end
    return decrement_value(total)
  end

  private

  def decrement_value(amount)
    offset = payroll_line.variable4 || 0
    offset2 = payroll_line.variable5 || 0
    known_offset = (attendance_summary.known_absence - offset)
    known_offset = 0 if known_offset < 0
    unknown_offset = (attendance_summary.unknown_absence - offset2)
    unknown_offset = 0 if unknown_offset < 0
    value = amount - ((known_offset + unknown_offset) * payroll_line.variable3)
    value > 0 ? value.round(-2) : 0
  end

end
