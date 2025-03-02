class Payroll::Formula::PeriodProportionalCalculator < Payroll::Formula::ApplicationCalculator

  # variable1 amount if full period presence
  # variable2 = include sick day? 1 is true, anything else is false

  def calculate
    fraction = if include_sick_day?(payroll_line)
      (attendance_summary.work_days.to_d + attendance_summary.sick_leave) / attendance_summary.total_day.to_d
    else
      attendance_summary.work_days.to_d / attendance_summary.total_day.to_d
    end
    (fraction * payroll_line.variable1.to_d).round(payslip_round)
  end

  def self.main_amount(payroll_line)
    payroll_line.variable1
  end

  def self.full_amount(payroll_line)
    payroll_line.variable1
  end

  private
  def include_sick_day?(payroll_line)
    payroll_line.variable3 == 1
  end

  def payslip_round
    (Setting.get('payslip_round') || -2).to_i
  end
end
