class BookEmployeeAttendance::DestroyService < ApplicationService
  def execute_service
    book_employee_attendance = BookEmployeeAttendance.find(params[:id])
    raise RecordNotFound.new(params[:id], BookEmployeeAttendance.model_name.human) if book_employee_attendance.nil?

    if book_employee_attendance.destroy
      render_json({ message: "#{book_employee_attendance.id} sukses dihapus" })
    else
      render_error_record(book_employee_attendance)
    end
  end
end
