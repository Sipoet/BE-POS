class User::ShowService < BaseService

  def execute_service
    user = User.find_by(username: @params[:username])
    raise BaseService::RecordNotFound.new(@params[:username],User.name) if user.nil?
    render_json(UserSerializer.new(user))
  end

end
