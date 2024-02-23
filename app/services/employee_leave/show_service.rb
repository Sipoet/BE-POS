class EmployeeLeave::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    employee_leave = EmployeeLeave.find(id: params[:id])
    raise RecordNotFound.new(params[:id],EmployeeLeave.model_name.human) if employee_leave.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(EmployeeLeaveSerializer.new(@employee_leaves,options))
  end

  def extract_params
    allowed_columns = EmployeeLeave::TABLE_HEADER.map(&:name)
    allowed_fields = [:employee_leave]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @included = result.included
    @field = result.field
  end

end
