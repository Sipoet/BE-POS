class Payroll::Calculator

  def initialize(payroll_line:, attendance_summary:, recent_sum: 0, employee:)
    raise "should be payroll line, got #{payroll_line.class} #{payroll_line} instead" unless payroll_line.is_a?(PayrollLine)
    @payroll_line = payroll_line
    raise "should be payroll line, got #{attendance_summary.class} #{attendance_summary} instead" unless attendance_summary.is_a?(AttendanceAnalyzer::Result)
    @attendance_summary = attendance_summary
    @recent_sum = recent_sum || 0
    @employee = employee
  end

  def calculate!
    begin
      klass = "Payroll::Formula::#{@payroll_line.formula.to_s.classify}Calculator".constantize
    rescue
      raise "payroll formula #{@payroll_line.formula} not supported"
    end
    formula_calculator = klass.new(@payroll_line,@attendance_summary,@recent_sum,@employee)
    amount = formula_calculator.calculate
    @meta = formula_calculator.meta
    amount
  end

  def get_meta(key)
    return nil if @meta.nil?
    @meta[key.to_sym]
  end
end
