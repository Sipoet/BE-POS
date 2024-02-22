class PayslipCalculator

  def initialize(payslip)
    raise "should be payslip, got #{payslip.class} #{payslip} instead" unless payslip.is_a?(Payslip)
    @payslip = payslip
  end

  def calculate_and_filled
    result = calculate
    @payslip.gross_salary = result.gross_salary
    @payslip.tax_amount = result.tax_amount
    @payslip.nett_salary = result.nett_salary
    @payslip
  end


  def calculate
    result = Result.new
    payslip_lines = @payslip.payslip_lines
                            .to_a
                            .select{|row| !row.marked_for_destruction?}
    result.gross_salary = payslip_lines.sum(0.0) do |line|
      line.earning? ? line.amount : 0
    end
    result.tax_amount = payslip_lines.sum(0.0) do |line|
      line.tax? ? line.amount : 0
    end
    result.nett_salary = payslip_lines.sum(0.0) do |line|
      line.earning? ? line.amount : (-1 * line.amount)
    end
    result
  end

  private

  class Result
    attr_accessor :gross_salary, :tax_amount, :nett_salary
  end


end
