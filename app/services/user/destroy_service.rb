class User::DestroyService < BaseService

  def execute_service
    user = User.find_by(username: @params[:username])
    raise BaseService::RecordNotFound.new(@params[:username],User.name) if user.nil?
    begin
      User.transaction do
        user.destroy!
      end
      render_json({message: "#{user.username} sukses dihapus"})
    rescue => e
      Rails.logger.debug e.message
      render_error_record(user)
    end
  end

end
