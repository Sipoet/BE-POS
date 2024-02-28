class Payroll::Formula::FulltimeCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    work_days = attendance_summary.work_days + attendance_summary.paid_time_off
    if attendance_summary.employee_worked_days < attendance_summary.total_day
      if work_days < attendance_summary.employee_worked_days
        return 0
      end
      return (attendance_summary.employee_worked_days.to_d/ attendance_summary.total_day.to_d * payroll_line.variable1).round
    end
    if work_days < attendance_summary.total_day
      return 0
    end
    return payroll_line.variable1

  end

end
