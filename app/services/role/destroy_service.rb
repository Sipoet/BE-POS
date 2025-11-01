class Role::DestroyService < ApplicationService
  def execute_service
    role = Role.find(params[:id])
    raise RecordNotFound.new(params[:id], Role.model_name.human) if role.nil?

    if role.destroy
      render_json({ message: "#{role.name} sukses dihapus" })
    else
      render_error_record(role)
    end
  end
end
