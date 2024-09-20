class Payroll::Formula::FulltimeScheduleCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    last_date = attendance_summary.details.last.date
    begin_date = employee.start_working_date
    return 0 if ((begin_date..last_date).to_a.length < 7 && attendance_summary.is_last_work)
    leave_day_without_sick = attendance_summary.known_absence + attendance_summary.unknown_absence
    total = payroll_line.variable1.to_d
    if  attendance_summary.is_first_work || attendance_summary.is_last_work
      total = (total * attendance_summary.work_days.to_d / attendance_summary.total_day.to_d).round(-2)
    end
    return decrement_value(total)
  end

  private

  def decrement_value(amount)
    offset = payroll_line.variable3 || 0
    offset2 = payroll_line.variable4 || 0
    known_offset = (attendance_summary.known_absence - offset)
    known_offset = 0 if known_offset < 0
    unknown_offset = (attendance_summary.unknown_absence - offset2)
    unknown_offset = 0 if unknown_offset < 0
    value = amount - (payroll_line.variable2 * known_offset) - (payroll_line.variable2 * unknown_offset)
    value > 0 ? value : 0
  end

  def self.main_amount(payroll_line)
    payroll_line.variable1
  end

  def self.full_amount(payroll_line)
    payroll_line.variable1
  end
end
