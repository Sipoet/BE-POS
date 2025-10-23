class Payroll::Formula::BasicCalculator < Payroll::Formula::ApplicationCalculator
  def calculate
    payroll_line.variable1
  end

  def self.main_amount(payroll_line)
    payroll_line.variable1
  end

  def self.full_amount(payroll_line)
    payroll_line.variable1
  end
end
