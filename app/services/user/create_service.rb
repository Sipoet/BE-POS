class User::CreateService < BaseService

  def execute_service
    permitted_params = @params.required(:user)
                              .permit(:username,:role,:email,:password,:password_confirmation)
    user = User.new(permitted_params)
    if user.save
      render_json(UserSerializer.new(user),{status: :created})
    else
      render_error_record(user)
    end
  end

end
