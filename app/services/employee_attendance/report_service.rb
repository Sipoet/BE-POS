# frozen_string_literal: true

class EmployeeAttendance::ReportService < ApplicationService
  def execute_service
    extract_params
    employees = find_employees
    attendances = employees.map { |employee| attendance_summary_of(employee) }
    render_json({ data: attendances.map { |summary| { attributes: summary, type: 'employee_attendance_report' } } })
  end

  private

  def attendance_summary_of(employee)
    AttendanceAnalyzer.new(employee: employee,
                           start_date: @start_date,
                           end_date: @end_date)
                      .analyze
  end

  def find_employees
    employees = if @employee_ids.present?
                  Employee.where(id: @employee_ids)
                else
                  attendance_employee_ids = EmployeeAttendance.where(date: @start_date..@end_date)
                                                              .distinct(:employee_id)
                                                              .pluck(:employee_id)
                  Employee.where(id: attendance_employee_ids)
                end
    employees = employees.where(status: @employee_status) if @employee_status.present?
    employees = employees.where(payroll_id: @payroll_ids) if @payroll_ids.present?
    employees
  end

  def extract_params
    permitted_params = params.permit(:start_date, :end_date, :employee_status, payroll_ids: [], employee_ids: [])
    @employee_ids = permitted_params[:employee_ids]
    @payroll_ids = permitted_params[:payroll_ids]
    @employee_status = permitted_params[:employee_status]
    @start_date = Date.parse(permitted_params[:start_date])
    @end_date = Date.parse(permitted_params[:end_date])
  end
end
