class ApplicationController < ActionController::API

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[username])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar])
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
      render_error("#{e.message} #{e.backtrace.to_s}")
    end
  end

  private

  def render_error(message)
    render json: {message: message}, status: 500
  end
end
