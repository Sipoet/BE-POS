class Employee::DeactivateService < ApplicationService

  def execute_service
    employee = Employee.find_by(code: params[:code])
    raise RecordNotFound if employee.nil?
    if employee.inactive!
      render_json(EmployeeSerializer.new(employee))
    else
      render_error_record(employee)
    end
  end

end
