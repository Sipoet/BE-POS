class ApplicationController < ActionController::API

  before_action :configure_permitted_parameters, if: :devise_controller?

  protected

  def configure_permitted_parameters
    devise_parameter_sanitizer.permit(:sign_in, keys: %i[username])
    devise_parameter_sanitizer.permit(:account_update, keys: %i[name avatar])
  end

  def run_service_default(controller)
    action_name = controller.action_name
    controller_name = controller.controller_name
    begin
      class_name = "#{controller_name.classify}::#{action_name.classify}Service"
      klass = class_name.constantize
      klass.run(controller)
    rescue NameError => e
      render_error('service klass not found')
    end
  end

  private

  def render_error(message)
    render json: {error_message: message}, status: :conflict
  end
end
