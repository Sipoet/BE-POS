class Payslip::GeneratePayslipService < ApplicationService
  def execute_service
    extract_params
    employees = find_employees
    payrolls = Payroll.where(id: employees.map(&:payroll_id))
                      .includes(:payroll_lines)
                      .index_by(&:id)

    payslips = []
    @commission_analyzer = CommissionAnalyzer.new(start_date: @start_date, end_date: @end_date)
    @commission_analyzer.analyze
    ApplicationRecord.transaction do
      employees.each do |employee|
        payroll = payrolls[employee.payroll_id]
        payslips << create_payslip!(payroll, employee)
      end
    end
    payslips.compact!
    render_json(PayslipSerializer.new(payslips, { include: %w[employee payroll],
                                                  field: { employee: ['name'], payroll: ['name'] },
                                                  meta: { message: 'success generate payslip' } }),
                { status: :created })
  end

  private

  def create_payslip!(payroll, employee)
    attendance_summary = attendance_summary_of(payroll, employee)
    return nil if attendance_summary.work_days == 0

    payslip = Payslip.find_or_initialize_by(
      payroll: payroll,
      employee: employee,
      start_date: @start_date,
      end_date: @end_date
    )
    payslip.sick_leave = attendance_summary.sick_leave.to_i
    payslip.known_absence = attendance_summary.known_absence.to_i
    payslip.unknown_absence = attendance_summary.unknown_absence.to_i
    payslip.total_day = attendance_summary.total_day.to_i
    payslip.late = attendance_summary.late
    overtime_hour = attendance_summary.overtime_hours
    payslip.overtime_hour = overtime_hour
    payslip.paid_time_off = payroll.paid_time_off
    recent_sum = 0
    payslip.payslip_lines.map(&:mark_for_destruction)
    payroll.payroll_lines.order(row: :asc)
           .each do |payroll_line|
      calculator =  Payroll::Calculator.new(payroll_line: payroll_line,
                                            attendance_summary: attendance_summary,
                                            employee: employee,
                                            recent_sum: recent_sum,
                                            commission_analyzer: @commission_analyzer)
      amount = calculator.calculate!
      payslip.overtime_hour = calculator.get_meta(:total_overtime) if payroll_line.overtime_hour?
      next if amount == 0

      payslip.payslip_lines.build(
        description: payroll_line.description,
        group: payroll_line.group,
        payroll_type: payroll_line.payroll_type,
        formula: payroll_line.formula,
        variable1: payroll_line.variable1,
        variable2: payroll_line.variable2,
        variable3: payroll_line.variable3,
        variable4: payroll_line.variable4,
        variable5: payroll_line.variable5,
        amount: amount
      )
      recent_sum += amount * (payroll_line.earning? ? 1 : -1)
    end

    book_payslip_lines = add_booked_payslip_line(payslip)

    payslip.work_days = attendance_summary.total_full_work_days > 0 ? attendance_summary.total_full_work_days : attendance_summary.work_days
    payslip.notes = "HK#{payslip.work_days},TK#{attendance_summary.total_day},OT#{overtime_hour},TK#{attendance_summary.unknown_absence},IZ#{attendance_summary.known_absence},SKS#{attendance_summary.sick_leave}"
    calculate_payslip(payslip)
    payslip.save!
    book_payslip_lines.each { |book_payslip_line| book_payslip_line.save! }
    payslip.reload
    payslip
  end

  def add_booked_payslip_line(payslip)
    book_payslip_lines = []
    BookPayslipLine.where(employee_id: payslip.employee_id,
                          transaction_date: @start_date..@end_date)
                   .each do |book_payslip_line|
      book_payslip_line.payslip_line = payslip.payslip_lines.build(
        description: book_payslip_line.description,
        group: book_payslip_line.group,
        payroll_type: book_payslip_line.payroll_type,
        formula: :basic,
        variable1: book_payslip_line.amount,
        amount: book_payslip_line.amount
      )
      book_payslip_lines << book_payslip_line
    end
    book_payslip_lines
  end

  def calculate_payslip(payslip)
    PayslipCalculator.new(payslip).calculate_and_filled
  end

  def attendance_summary_of(payroll, employee)
    AttendanceAnalyzer.new(payroll: payroll,
                           employee: employee,
                           start_date: @start_date,
                           end_date: @end_date)
                      .analyze
  end

  def find_employees
    employees = Employee.all
    employees = employees.where(id: @employee_ids) if @employee_ids.present?
    employees
  end

  def extract_params
    permitted_params = params.permit(:start_date, :end_date, employee_ids: [])
    @employee_ids = permitted_params[:employee_ids]
    @start_date = Date.parse(permitted_params[:start_date])
    @end_date = Date.parse(permitted_params[:end_date])
  end
end
