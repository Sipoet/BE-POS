class Role::ShowService < ApplicationService

  include JsonApiDeserializer
  def execute_service
    extract_params
    role = Role.find(id: params[:id])
    raise RecordNotFound.new(params[:id],Role.model_name.human) if role.nil?
    options = {
      fields: @fields,
      params:{include: @included},
      include: @included
    }
    render_json(RoleSerializer.new(@roles,options))
  end

  def extract_params
    allowed_columns = Role::TABLE_HEADER.map(&:name)
    allowed_fields = [:role]
    result = dezerialize_table_params(params,
      allowed_fields: allowed_fields,
      allowed_columns: allowed_columns)
    @included = result.included
    @field = result.field
  end

end
