class Payroll::Formula::OvertimeHourCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    max_hour_per_day = payroll_line.variable4.presence || 1
    max_hour_per_day = 1 if max_hour_per_day == 0
    @total_overtime = 0
    offset = payroll_line.variable2
    attendance_summary.details.each do|detail|
      min_work_hour = payroll_line.variable3
      min_work_hour += 1 if detail.is_late
      if detail.work_hours >= min_work_hour + offset
        @total_overtime += [(detail.work_hours - min_work_hour),max_hour_per_day].min
        # Rails.logger.info "work_hours #{detail.work_hours} offset : #{offset}, total overtime #{@total_overtime} max hour: #{max_hour_per_day}"
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
