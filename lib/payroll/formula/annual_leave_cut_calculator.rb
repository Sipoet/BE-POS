class Payroll::Formula::AnnualLeaveCutCalculator < Payroll::Formula::ApplicationCalculator
  def calculate
    absence = attendance_summary.known_absence + attendance_summary.unknown_absence
    return payroll_line.variable1 if absence == 0
    return 0 if payroll_line.variable2.blank?
    return payroll_line.variable3 || 0 if absence <= payroll_line.variable2
    return 0 if payroll_line.variable4.blank?
    return payroll_line.variable5 || 0 if absence <= payroll_line.variable4

    0
  end

  def self.main_amount(payroll_line)
    payroll_line.variable1
  end

  def self.full_amount(payroll_line)
    payroll_line.variable1
  end
end
