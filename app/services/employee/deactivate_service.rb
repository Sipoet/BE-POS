class Employee::DeactivateService < ApplicationService

  def execute_service
    employee = Employee.find(params[:id])
    raise RecordNotFound if employee.nil?
    if employee.inactive!
      render_json(EmployeeSerializer.new(employee))
    else
      render_error_record(employee)
    end
  end

end
