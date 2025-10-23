class Role::DestroyService < ApplicationService
  def execute_service
    role = Role.find(params[:id])
    raise RecordNotFound.new(params[:id], Role.model_name.human) if role.nil?

    if Role.superadmin?(role)
      role.errors.add(:base, 'role superadmin tidak boleh dihapus')
      render_error_record(role)
      return
    end
    if role.destroy
      render_json({ message: "#{role.name} sukses dihapus" })
    else
      render_error_record(role)
    end
  end
end
