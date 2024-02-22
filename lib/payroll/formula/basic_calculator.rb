class Payroll::Formula::BasicCalculator < Payroll::Formula::ApplicationCalculator

  def calculate
    payroll_line.variable1
  end

end
