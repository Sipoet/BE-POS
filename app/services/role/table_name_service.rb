class Role::TableNameService < ApplicationService

  def execute_service
    table_names = []
    search_text = params.permit(:search_text)[:search_text]
    Dir["#{Rails.root}/app/models/*.rb"].each do |path|
      table_name = path.split('/').last
      table_name = table_name.gsub(/(\w+)\.rb/,'\1')
      next if ['application_record','application_model'].include?(table_name)
      if search_text.present? && table_name.include?(search_text)
        table_names << table_name
      elsif search_text.blank?
        table_names << table_name
      end
    end
    render_json({
      data: table_names.map{|table_name|{id: table_name, name: table_name}}
    })
  end

end
