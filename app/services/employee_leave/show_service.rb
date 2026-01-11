class EmployeeLeave::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    employee_leave = EmployeeLeave.find(params[:id])
    raise RecordNotFound.new(params[:id], EmployeeLeave.model_name.human) if employee_leave.nil?

    options = {
      field: @field,
      params: { include: @included },
      include: @included
    }
    render_json(EmployeeLeaveSerializer.new(employee_leave, options))
  end

  def extract_params
    @table_definition = Datatable::DefinitionExtractor.new(EmployeeLeave)
    allowed_includes = [:employee_leave]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definition: @table_definition)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: EmployeeLeave)
  end
end
