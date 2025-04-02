class Home::SettingService < ApplicationService

  def execute_service
    menus = find_menus(@current_user.role)
    table_columns = find_table_columns(@current_user.role)

    render_json({menus: menus, table_columns: table_columns}.as_json)
  end

  private

  def find_menus(role)
    return all_menus if role.name == Role::SUPERADMIN
    role.access_authorizes
        .group_by(&:controller)
        .each_with_object({}) do|(controller,values),obj|
          obj[controller.singularize.camelize(:lower)] = values.map{|access|access.action.camelize(:lower)}
        end
  end

  def all_menus
    controller_names = []
    Dir["#{Rails.root}/app/controllers/*_controller.rb"].each do |path|
      controller_name = path.split('/').last
      controller_name = controller_name.gsub(/(\w+)_controller\.rb/,'\1')
      next if ['application','assets'].include?(controller_name)
      controller_names << controller_name
    end
    controller_names.uniq!
    Rails.application.routes.routes.group_by{|route| route.defaults[:controller]}
    .each_with_object({}) do |(controller,routes),obj|
      next if controller.blank?
      next unless controller_names.include?(controller)
      obj[controller.singularize.camelize(:lower)] = routes.map{|route| route.defaults[:action].strip.camelize(:lower)}
                                                           .uniq
    end
  end

  def find_table_columns(role)
    table_names = []
    Dir["#{Rails.root}/app/models/*.rb"].each do |path|
      table_name = path.split('/').last
      table_name = table_name.gsub(/(\w+)\.rb/,'\1')
      next if ['application_record','application_model'].include?(table_name)
      table_names << table_name
    end

    Dir["#{Rails.root}/app/models/ipos/*.rb"].each do |path|
      table_name = path.split('/').last
      table_name = table_name.gsub(/(\w+)\.rb/,'\1')
      next if ['activity_log'].include?(table_name)
      table_names << "Ipos::#{table_name.classify}"
    end
    allowed_columns = role.column_authorizes.group_by(&:table)
    table_names.each_with_object({}) do |table_name,obj|
      klass = table_name.classify.constantize
      table_key = table_name.camelize(:lower)
      if role.name == Role::SUPERADMIN
        obj[table_key] = TableColumnSerializer.new(Datatable::DefinitionExtractor.new(klass).column_definitions).as_json
        next
      end
      columns = allowed_columns[table_name]
      next if columns.blank?
      columns = columns.index_by(&:column)
      table_def = Datatable::DefinitionExtractor.new(klass).column_definitions
      selected_columns = table_def.select{|table_column|columns[table_column.name.to_s].present? }
      obj[table_key] = TableColumnSerializer.new(selected_columns)
    end
  end

end
