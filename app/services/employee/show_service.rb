class Employee::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    employee = Employee.find(params[:id])
    raise RecordNotFound.new(params[:id],Employee.model_name.human) if employee.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(EmployeeSerializer.new(employee,options))
  end

  def extract_params
    allowed_columns = Employee::TABLE_HEADER.map(&:name)
    allowed_fields = [:employee, :work_schedules, :employee_day_offs]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @included = result.included
    @fields = result.fields
  end

end
