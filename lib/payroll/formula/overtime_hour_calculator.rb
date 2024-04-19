class Payroll::Formula::OvertimeHourCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    max_hour_per_day = payroll_line.variable3.presence || 1
    max_hour_per_day = 1 if max_hour_per_day == 0
    @total_overtime = 0
    attendance_summary.details.each do|detail|
      offset = detail.is_late ? payroll_line.variable2  : payroll_line.variable2
      if detail.work_hours > offset
        @total_overtime += [(detail.work_hours - offset),max_hour_per_day].min
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
