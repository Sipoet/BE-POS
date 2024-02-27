class ApplicationController < ActionController::API
  include UserAuthorizer


  before_action :configure_permitted_parameters, if: :devise_controller?

  rescue_from 'ForbiddenError' do |exception|
    render json:{message: '401 Unauthorized'}, status: :unauthorized
  end

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[username])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar])
  end

  def authorize_user!
    authenticate_user!
    set_paper_trail_whodunnit
    authorize_role!(current_user.role)
  end

  def run_service(service_klass = nil)
    service_klass.run(self)
  end

  def run_service_default
    begin
      class_name = "#{controller_name.classify}::#{action_name.classify}Service"
      service_klass = class_name.constantize
      service_klass.run(self)
    rescue NameError => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace.to_s
      render_error("Internal Server Error")
    end
  end

  private

  def render_error(message)
    render json: {message: message}, status: 500
  end
end
class ForbiddenError < StandardError; end
