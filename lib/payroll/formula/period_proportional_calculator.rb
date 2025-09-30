class Payroll::Formula::PeriodProportionalCalculator < Payroll::Formula::ApplicationCalculator

  # variable1 = amount of pay
  # variable2 = how many day get amount of pay
  # variable3 = include sick day? 1 is true, anything else is false

  def calculate
    fraction = attendance_summary.work_days.to_d
    fraction += attendance_summary.sick_leave if include_sick_day?(payroll_line)
    separator = (payroll_line.variable2 || 1).to_d
    (fraction * payroll_line.variable1.to_d / separator).round(payslip_round)
  end

  def self.main_amount(payroll_line)
    payroll_line.variable1
  end

  def self.full_amount(payroll_line)
    payroll_line.variable1 / payroll_line.variable2 * 29
  end

  private
  def include_sick_day?(payroll_line)
    payroll_line.variable3 == 1
  end

  def payslip_round
    (Setting.get('payslip_round') || -2).to_i
  end
end
