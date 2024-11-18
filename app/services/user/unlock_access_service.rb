class User::UnlockAccessService < ApplicationService

  def execute_service
    user = User.find_by(username: @params[:username])
    raise ApplicationService::RecordNotFound.new(@params[:id],User.name) if user.nil?
    user.unlock_access!
    render_json({message: 'success'})
  end

end
