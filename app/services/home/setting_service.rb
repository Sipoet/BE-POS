class Home::SettingService < ApplicationService

  def execute_service
    menus = find_menus(@current_user.role)
    table_columns = find_table_columns(@current_user.role)
    render_json({data: {menus: menus, table_columns: table_columns}})
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
    Rails.application.routes.routes.group_by{|route| route.defaults[:controller]}
    .each_with_object({}) do |(controller,routes),obj|
      next if controller.blank?
      next unless controller_names.include?(controller)
      obj[controller.singularize.camelize(:lower)] = routes.map{|route| route.defaults[:action].camelize(:lower)}
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
    table_names += ['ipos::Supplier','ipos::Item','ipos::Brand','ipos::Item_type']
    allowed_columns = role.column_authorizes.group_by(&:table)
    table_names.each_with_object({}) do |table_name,obj|
      klass = table_name.classify.constantize
      if role.name == Role::SUPERADMIN
        obj[table_name.camelize(:lower)] = klass::TABLE_HEADER
      else
        columns = allowed_columns[table_name]
        next if columns.blank?
        table_headers = klass::TABLE_HEADER.index_by(&:name)
        obj[table_name.camelize(:lower)] = columns.map do |authorize|
          table_headers[authorize.column.to_sym]
        end.compact
      end

    end
  end

end
