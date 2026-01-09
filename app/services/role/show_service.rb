class Role::ShowService < ApplicationService
  include JsonApiDeserializer
  def execute_service
    extract_params
    role = Role.find(params[:id])
    raise RecordNotFound.new(params[:id], Role.model_name.human) if role.nil?

    options = {
      field: @field,
      params: { include: @included },
      include: @included
    }
    render_json(RoleSerializer.new(role, options))
  end

  def extract_params
    @table_definitions = Datatable::DefinitionExtractor.new(Role)
    allowed_includes = %i[role column_authorizes access_authorizes role_work_schedules]
    result = deserialize_table_params(params,
                                      allowed_includes: allowed_includes,
                                      table_definitions: @table_definitions)
    @included = result.included
    @fields = filter_authorize_fields(fields: result.fields, record_class: Role)
  end
end
