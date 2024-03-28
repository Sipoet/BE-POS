class Payroll::Formula::OvertimeHourCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    max_hour_per_day = payroll_line.variable3.presence || 1
    max_hour_per_day = 1 if max_hour_per_day == 0
    @total_overtime = attendance_summary.overtime_hours.sum(0.0) do|hour|
      offset_hour = hour < payroll_line.variable2 ? 0 : hour
      [offset_hour, max_hour_per_day].min
    end
    attendance_summary.overtime_hours = [@total_overtime]
    @total_overtime.to_d * payroll_line.variable1
  end

  def meta
    {
      total_overtime: @total_overtime
    }
  end
end
