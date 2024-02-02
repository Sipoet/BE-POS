class User::ShowService < ApplicationService

  def execute_service
    user = User.find_by(username: @params[:username])
    raise ApplicationService::RecordNotFound.new(@params[:username],User.name) if user.nil?
    render_json(UserSerializer.new(user))
  end

end
