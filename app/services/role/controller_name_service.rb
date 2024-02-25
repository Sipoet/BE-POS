class Role::ControllerNameService < ApplicationService

  def execute_service
    controller_names = find_controllers
    render_json({
      data: controller_names.map{|controller|{id: controller, name: controller}}
    })
  end

  private

  def find_controllers
    controller_names = []
    search_text = params.permit(:search_text)[:search_text]
    Dir["#{Rails.root}/app/controllers/*_controller.rb"].each do |path|
      controller_name = path.split('/').last
      controller_name = controller_name.gsub(/(\w+)_controller\.rb/,'\1')
      next if ['application','assets'].include?(controller_name)
      controller_names << controller_name

    end
    return controller_names if search_text.blank?
    controller_names.select{|controller_name| controller_name.include?(search_text)}
  end

end
