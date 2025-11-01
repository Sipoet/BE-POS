class Payroll::Formula::OvertimeHourCalculator < Payroll::Formula::ApplicationCalculator
  # variable1 = amount per hour
  # variable2 = offset when get overtime
  # variable3 = how many work hour include rest hour per day, if empty or zero, how many hours based on scheduled
  # variable4 = max hour overtime calculated
  # variable5 = how many hour added as penalty to become overtime if late that day

  def calculate
    max_hour_per_day = payroll_line.variable4.presence || 1
    max_hour_per_day = 1 if max_hour_per_day == 0
    @total_overtime = 0
    offset = payroll_line.variable2
    min_work_calc = ->(_detail) { payroll_line.variable3.to_d }
    if payroll_line.variable3 == 0 || payroll_line.variable3.blank?
      min_work_calc = lambda { |detail|
        detail.is_late ? detail.scheduled_work_hours.to_d + payroll_line.variable5 : detail.scheduled_work_hours.to_d
      }
    end
    attendance_summary.details.each do |detail|
      next unless detail.allow_overtime

      min_work_hour = min_work_calc.call(detail)
      if detail.work_hours >= min_work_hour + offset
        @total_overtime += [(detail.work_hours - min_work_hour), max_hour_per_day].min
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

  def self.main_amount(payroll_line)
    payroll_line.variable1
  end

  def self.full_amount(_payroll_line)
    0
  end
end
