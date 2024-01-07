class User::UpdateService < BaseService

  def execute_service
    permitted_params = @params.required(:user)
                              .permit(:role,:email,:password,:password_confirmation)
    user = User.find_by(username: @params[:username])
    raise BaseService::RecordNotFound.new(@params[:username],User.name) if user.nil?
    if user.update(permitted_params)
      render_json(UserSerializer.new(user.reload))
    else
      render_error_record(user)
    end
  end

end
