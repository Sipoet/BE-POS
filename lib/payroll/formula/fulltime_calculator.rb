class Payroll::Formula::FulltimeCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    if attendance_summary.employee_worked_days < attendance_summary.total_day
      if attendance_summary.work_days < attendance_summary.employee_worked_days
        return 0
      end
      return (attendance_summary.employee_worked_days/ attendance_summary.total_day * payroll_line.variable1).round
    end
    if attendance_summary.work_days < attendance_summary.total_day
      return 0
    end
    return payroll_line.variable1

  end

end
