class Payroll::Formula::FulltimeCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    leave_day_without_sick = attendance_summary.known_absence + attendance_summary.unknown_absence
    if attendance_summary.employee_worked_days < attendance_summary.total_day
      if leave_day_without_sick > 0
        return 0
      end
      return (attendance_summary.employee_worked_days.to_d/ attendance_summary.total_day.to_d * payroll_line.variable1).round
    end
    if leave_day_without_sick > 0
      return 0
    end
    return payroll_line.variable1

  end

end
