class Employee::ShowService < ApplicationService

  def execute_service
    employee = Employee.find_by(code: params[:code])
    raise RecordNotFound if employee.nil?
    render_json(EmployeeSerializer.new(employee))
  end

end
