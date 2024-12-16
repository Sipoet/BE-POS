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
    @table_definitions = Datatable::DefinitionExtractor.new(Employee)
    allowed_fields = [:employee, :work_schedules, :employee_day_offs,:payroll, :role]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @included = result.included
    @fields = result.fields
  end

end
