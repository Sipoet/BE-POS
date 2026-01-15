class Role::ActionNameService < ApplicationService
  READ_ACTION = %w[index show]
  def execute_service
    extract_params
    actions = find_controller_actions
    if @page == 1
      render_json({
                    data: actions.map { |action| { id: action, name: action.capitalize } }
                  })
    else
      render_json({
                    data: []
                  })
    end
  end

  private

  def extract_params
    permitted_params = params.permit(:controller_name, :search_text, page: %i[page limit])
    @controller_name = permitted_params[:controller_name]
    @search_text = permitted_params[:search_text]
    @page = begin
      permitted_params[:page].fetch(:page, 1).to_i
    rescue StandardError
      1
    end
  end

  def find_controller_actions
    return [] if @controller_name.blank?

    actions = []
    Rails.application.routes.routes.each do |route|
      next unless route.defaults[:controller] == @controller_name

      action = route.defaults[:action].strip.downcase
      action = 'read' if READ_ACTION.include? action
      actions << action
    end
    actions.uniq!
    return actions if @search_text.blank?

    downcased_text = @search_text.downcase
    actions.select { |action| action.include?(downcased_text) }
  end
end
