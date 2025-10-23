class Employee::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    employee = Employee.find(params[:id])
    raise RecordNotFound.new(params[:id], Employee.model_name.human) if employee.nil?

    options = {
      fields: @fields,
      params: { include: @included },
      include: @included
    }
    render_json(EmployeeSerializer.new(employee, options))
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(Employee)
    allowed_includes = %i[employee work_schedules employee_day_offs payroll role]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Employee)
  end
end
