class Role::ControllerNameService < ApplicationService

  def execute_service
    extract_params
    controller_names = find_controllers
    if @page == 1
      render_json({
        data: controller_names.map{|controller|{id: controller, name: controller}}
      })
    else
      render_json({
        data: []
      })
    end
  end

  private
  def extract_params
    permitted_params = params.permit(:search_text,page:[:page,:limit])
    @search_text = permitted_params[:search_text]
    @page = permitted_params[:page].fetch(:page,1).to_i rescue 1
  end

  def find_controllers
    controller_names = []

    Dir["#{Rails.root}/app/controllers/*_controller.rb"].each do |path|
      controller_name = path.split('/').last
      controller_name = controller_name.gsub(/(\w+)_controller\.rb/,'\1')
      next if ['application','assets'].include?(controller_name)
      controller_names << controller_name

    end
    return controller_names if @search_text.blank?
    controller_names.select{|controller_name| controller_name.include?(@search_text)}
  end

end
