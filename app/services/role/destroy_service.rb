class Role::DestroyService < ApplicationService

  def execute_service
    role = Role.find(id: params[:id])
    raise RecordNotFound.new(params[:id],Role.model_name.human) if role.nil?
    if role.destroy
      render_json(RoleSerializer.new(role),{status: :created})
    else
      render_error_record(role)
    end
  end
end
