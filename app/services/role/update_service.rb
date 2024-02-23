class Role::UpdateService < ApplicationService

  def execute_service
    role = Role.find(id: params[:id])
    raise RecordNotFound.new(params[:id],Role.model_name.human) if role.nil?
    if record_save?(role)
      render_json({message: "#{role.name} sukses dihapus"})
    else
      render_error_record(role)
    end
  end

  def record_save?(role)
    ApplicationRecord.transaction do
      update_attribute(role)
      role.save!
    end
    return true
  rescue => e
    Rails.logger.errors e.message
    Rails.logger.errors e.backtrace
    return false
  end

  def update_attribute(role)
    allowed_columns = Role::TABLE_HEADER.map(&:key)
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    role.attributes = permitted_params
  end
end
