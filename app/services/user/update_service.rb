class User::UpdateService < ApplicationService

  def execute_service
    permitted_params = @params.required(:data)
                              .required(:attributes)
                              .permit(:role_id,:username,:email,:password,:password_confirmation)
    user = User.find_by(username: @params[:username])
    raise ApplicationService::RecordNotFound.new(@params[:username],User.name) if user.nil?
    if user.update(permitted_params)
      render_json(UserSerializer.new(user.reload))
    else
      render_error_record(user)
    end
  end

end
