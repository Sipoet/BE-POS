class Role::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    role = Role.find( params[:id])
    raise RecordNotFound.new(params[:id],Role.model_name.human) if role.nil?
    options = {
      field: @field,
      params:{include: @included},
      include: @included
    }
    render_json(RoleSerializer.new(role,options))
  end

  def extract_params
    allowed_columns = Role::TABLE_HEADER.map(&:name)
    allowed_fields = [:role, :column_authorizes,:access_authorizes,:role_work_schedules]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @included = result.included
    @field = result.fields
  end

end
