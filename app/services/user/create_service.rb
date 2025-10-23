class User::CreateService < ApplicationService
  def execute_service
    user = User.new
    if record_save?(user)
      options = {
        fields: @fields,
        include: ['role'],
        params: { include: ['role'] }
      }
      render_json(UserSerializer.new(user, options), { status: :created })
    else
      render_error_record(user)
    end
  end

  def record_save?(user)
    ApplicationRecord.transaction do
      update_attribute(user)
      user.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def update_attribute(user)
    allowed_columns = %i[role_id username password password_confirmation email]
    @fields = { user: %i[role username email] }
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(allowed_columns)
    user.attributes = permitted_params
  end
end
