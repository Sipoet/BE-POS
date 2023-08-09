class ApplicationController < ActionController::API

  protected

  def run_service_default(controller)
    action_name = controller.action_name
    controller_name = controller.controller_name
    debugger
    binding.pry
    begin
      class_name = "#{controller_name.classify}::#{action_name.classify}Service"
      
      puts class_name
      klass = class_name.constantize
      klass.run(controller)
    rescue => NameError
      render_error('service klass not found')  
    end
  end

  def render_error(message)
    render json: {error_message: message}, status: 422
  end
end
