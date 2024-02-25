class EmployeeLeave::DestroyService < ApplicationService

  def execute_service
    employee_leave = EmployeeLeave.find(params[:id])
    raise RecordNotFound.new(params[:id],EmployeeLeave.model_name.human) if employee_leave.nil?
    if employee_leave.destroy
      render_json(EmployeeLeaveSerializer.new(employee_leave),{status: :created})
    else
      render_error_record(employee_leave)
    end
  end
end
