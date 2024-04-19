class Payroll::Formula::FulltimeHourPerDayCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    full_work_days = 0
    attendance_summary.work_hours.each do |hour|
      if hour >= payroll_line.variable2
        full_work_days += 1
      end
    end
    attendance_summary.total_full_work_days = full_work_days
    total = payroll_line.variable1
    Rails.logger.info "==== full work #{full_work_days} total day #{attendance_summary.total_day}, work days #{attendance_summary.work_days} from GP #{payroll_line.variable1} "
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
