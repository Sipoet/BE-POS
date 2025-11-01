class Payroll::Formula::ApplicationCalculator
  attr_reader :payroll_line, :attendance_summary, :recent_sum, :employee, :commission_analyzer

  def initialize(payroll_line, attendance_summary, recent_sum = 0, employee, commission_analyzer)
    unless payroll_line.is_a?(PayrollLine)
      raise "should be payroll line, got #{payroll_line.class} #{payroll_line} instead"
    end

    @payroll_line = payroll_line
    unless attendance_summary.is_a?(AttendanceAnalyzer::Result)
      raise "should be attendance result, got #{attendance_summary.class} #{attendance_summary} instead"
    end

    @attendance_summary = attendance_summary
    @recent_sum = recent_sum || 0
    @employee = employee
    @commission_analyzer = commission_analyzer
  end

  def calculate
    raise 'should init on child class'
  end

  def self.main_amount(_payroll_line)
    raise 'should init on child class'
  end

  def self.full_amount(_payroll_line)
    raise 'should init on child class'
  end

  def meta
    {
      total_overtime: @total_overtime
    }
  end
end
