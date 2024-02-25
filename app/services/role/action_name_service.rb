class Role::ActionNameService < ApplicationService

  def execute_service
    actions = find_controller_actions
    render_json({
      data: actions.map{|action|{id: action, name: action}}
    })
  end

  private

  def find_controller_actions
    permitted_params = params.permit(:controller_name, :search_text)
    controller_name = permitted_params[:controller_name]
    search_text = permitted_params[:search_text]
    return [] if controller_name.blank?
    actions = []
    Rails.application.routes.routes.each do |route|
      actions << route.defaults[:action] if route.defaults[:controller] == controller_name
    end
    return actions if search_text.blank?
    actions.select{|action| action.include?(search_text)}
  end
end
