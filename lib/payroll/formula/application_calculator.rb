class Payroll::Formula::ApplicationCalculator

  attr_reader :payroll_line, :attendance_summary, :recent_sum, :employee
  def initialize(payroll_line,attendance_summary, recent_sum = 0, employee)
    raise "should be payroll line, got #{payroll_line.class} #{payroll_line} instead" unless payroll_line.is_a?(PayrollLine)
    @payroll_line = payroll_line
    raise "should be attendance result, got #{attendance_summary.class} #{attendance_summary} instead" unless attendance_summary.is_a?(AttendanceAnalyzer::Result)
    @attendance_summary = attendance_summary
    @recent_sum = recent_sum || 0
    @employee = employee
  end

  def calculate
    raise 'should init on child class'
  end

  def meta
    {
      total_overtime: @total_overtime
    }
  end
end
