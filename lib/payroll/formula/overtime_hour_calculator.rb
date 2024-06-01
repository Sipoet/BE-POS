class Payroll::Formula::OvertimeHourCalculator < Payroll::Formula::ApplicationCalculator
  # variable1 = amount per hour
  # variable2 = offset when get overtime
  # variable3 = how many work hour include rest hour per day
  # variable5 = how many hour added as penalty to become overtime if late that day

  def calculate
    max_hour_per_day = payroll_line.variable4.presence || 1
    max_hour_per_day = 1 if max_hour_per_day == 0
    @total_overtime = 0
    offset = payroll_line.variable2
    attendance_summary.details.each do|detail|
      min_work_hour = detail.scheduled_work_hours
      min_work_hour += (payroll_line.variable5 || 1) if detail.is_late
      if detail.work_hours >= min_work_hour + offset
        @total_overtime += [(detail.work_hours - min_work_hour),max_hour_per_day].min
      end
    end
    attendance_summary.overtime_hours = @total_overtime
    @total_overtime.to_d * payroll_line.variable1
  end

  def meta
    {
      total_overtime: @total_overtime
    }
  end
end
