class Payslip::GeneratePayslipService < ApplicationService

  def execute_service
    extract_params
    employees = find_employees
    payrolls = Payroll.where(id: employees.map(&:payroll_id))
                      .includes(:payroll_lines)
                      .index_by(&:id)

    payslips = []
    ApplicationRecord.transaction do
      employees.each do |employee|
        payroll = payrolls[employee.payroll_id]
        payslips << create_payslip!(payroll,employee)
      end
    end
    render_json(PayslipSerializer.new(payslips,{include:['employee','payroll'],
                                                field:{employee: ['name'],payroll:['name']},
                                                meta: {message: 'success generate payslip'}}),
                {status: :created})
  end

  private

  def create_payslip!(payroll,employee)
    attendance_summary = attendance_summary_of(payroll,employee)
    payslip = Payslip.find_or_initialize_by(
      payroll: payroll,
      employee: employee,
      start_date: @start_date,
      end_date: @end_date)

    payslip.sick_leave = attendance_summary.sick_leave.to_i
    payslip.known_absence = attendance_summary.known_absence.to_i
    payslip.unknown_absence = attendance_summary.unknown_absence.to_i
    payslip.work_days = attendance_summary.work_days.to_i
    payslip.total_day = attendance_summary.total_day.to_i
    payslip.late = attendance_summary.late.to_i
    overtime_hour = attendance_summary.overtime_hours.sum
    payslip.overtime_hour = overtime_hour
    payslip.paid_time_off = payroll.paid_time_off
    payslip.notes="HK#{attendance_summary.work_days},TK#{attendance_summary.total_day},OT#{overtime_hour},TK#{attendance_summary.unknown_absence},IZ#{attendance_summary.known_absence},SKS#{attendance_summary.sick_leave}"
    recent_sum = 0
    payslip.payslip_lines.map(&:mark_for_destruction)
    payroll.payroll_lines.each do |payroll_line|
      calculator =  Payroll::Calculator.new(payroll_line: payroll_line,
                                            attendance_summary: attendance_summary,
                                            recent_sum: recent_sum)
      amount = calculator.calculate!
      if payroll_line.overtime_hour?
        payslip.overtime_hour = calculator.get_meta(:total_overtime)
      end
      next if amount == 0
      payslip.payslip_lines.build(
        description: payroll_line.description,
        group: payroll_line.group,
        payslip_type: payroll_line.payroll_type,
        amount: amount)
      recent_sum += amount *(payroll_line.earning? ? 1 : -1)
    end
    calculate_payslip(payslip)
    payslip.save!
    payslip.reload
    payslip
  end

  def calculate_payslip(payslip)
    PayslipCalculator.new(payslip).calculate_and_filled
  end

  def attendance_summary_of(payroll,employee)
    AttendanceAnalyzer.new(payroll: payroll,
                           employee: employee,
                           start_date: @start_date,
                           end_date: @end_date)
                      .analyze
  end

  def find_employees
    employees = Employee.active
    employees = employees.where(id: @employee_ids) if @employee_ids.present?
    employees
  end

  def extract_params
    permitted_params = params.permit(:start_date, :end_date, employee_ids:[])
    @employee_ids = permitted_params[:employee_ids]
    @start_date = Date.parse(permitted_params[:start_date])
    @end_date = Date.parse(permitted_params[:end_date])
  end

end
