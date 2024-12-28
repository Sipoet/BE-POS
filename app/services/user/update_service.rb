class User::UpdateService < ApplicationService

  def execute_service
    user = User.find_by(username: params[:username])
    raise RecordNotFound.new(params[:username],User.model_name.human) if user.nil?
    if record_save?(user)
      options = {
        fields: @fields,
        include: ['role'],
        params:{include: ['role']}
      }
      render_json(UserSerializer.new(user, options))
    else
      render_error_record(user)
    end
  end

  def record_save?(user)
    ApplicationRecord.transaction do
      edit_attribute(user)
      user.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def edit_attribute(user)
    allowed_columns = [:role_id,:username,:password,:password_confirmation,:email]
    @fields = {user: [:role,:username,:email]}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    user.attributes = permitted_params
  end

end
