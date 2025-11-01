class EmployeeAttendance::DestroyService < ApplicationService
  def execute_service
    employee_attendance = EmployeeAttendance.find(params[:id])
    raise RecordNotFound.new(params[:id], EmployeeAttendance.model_name.human) if employee_attendance.nil?

    if employee_attendance.destroy
      render_json({ message: "#{employee_attendance.id} sukses dihapus" })
    else
      render_error_record(employee_attendance)
    end
  end
end
