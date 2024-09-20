class Payroll::Formula::SickLeaveCutCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    absence = attendance_summary.sick_leave
    if absence == 0
      return payroll_line.variable1
    end
    return 0 if payroll_line.variable2.blank?
    if absence <= payroll_line.variable2
      return (payroll_line.variable3 || 0)
    end
    return 0 if payroll_line.variable4.blank?
    if absence <= payroll_line.variable4
      return (payroll_line.variable5 || 0)
    end
    return 0
  end

  def self.main_amount(payroll_line)
    payroll_line.variable1
  end

  def self.full_amount(payroll_line)
    payroll_line.variable1
  end
end
