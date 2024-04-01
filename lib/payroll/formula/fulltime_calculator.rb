class Payroll::Formula::FulltimeCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    leave_day_without_sick = attendance_summary.known_absence + attendance_summary.unknown_absence
    if attendance_summary.employee_worked_days < attendance_summary.total_day
      if leave_day_without_sick > 0
        return decrement_value
      end
      return (attendance_summary.employee_worked_days.to_d/ attendance_summary.total_day.to_d * payroll_line.variable1).round
    end
    if leave_day_without_sick > 0
      return decrement_value
    end
    return payroll_line.variable1
  end

  private

  def decrement_value
    offset = payroll_line.variable3 || 0
    value = payroll_line.variable1 - (payroll_line.variable2 * (attendance_summary.known_absence - offset)) - (payroll_line.variable2 * attendance_summary.unknown_absence)
    value > 0 ? value : 0
  end

end
