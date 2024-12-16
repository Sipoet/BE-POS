class EmployeeLeave::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    employee_leave = EmployeeLeave.find( params[:id])
    raise RecordNotFound.new(params[:id],EmployeeLeave.model_name.human) if employee_leave.nil?
    options = {
      field: @field,
      params:{include: @included},
      include: @included
    }
    render_json(EmployeeLeaveSerializer.new(employee_leave,options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(EmployeeLeave)
    allowed_fields = [:employee_leave]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      table_definitions: @table_definitions)
    @included = result.included
    @field = result.fields
  end

end
