class Home::SettingService < ApplicationService
  def execute_service
    menus = find_menus(@current_user.role_id)
    table_columns = find_table_columns(@current_user.role_id)
    render_json({ menus: menus, table_columns: table_columns }.as_json)
  end

  private

  def find_menus(role_id)
    return all_menus if Role.superadmin?(role_id)

    checker = UserAuthorizer::AuthorizeChecker.new(role_id)
    checker.role_access
           .each_with_object({}) do |(controller, values), obj|
             obj[controller] = values.keys.map { |action| action.camelize(:lower) }
    end
  end

  def all_menus
    allowed_controllers = {}
    Dir["#{Rails.root}/app/controllers/**/*_controller.rb"].each do |path|
      filename, dir = path.split('app/controllers/').last.split('/').reverse
      next if %w[concerns action_mailbox rails active_storage].include? dir

      controller_name = filename.gsub(/(\w+)_controller\.rb/, '\1')
      next if %w[application assets mailers].include?(controller_name)

      controller_name = [dir, controller_name].compact.join('/')
      allowed_controllers[controller_name] = true
    end
    Rails.application.routes.routes.group_by { |route| route.defaults[:controller] }
         .each_with_object({}) do |(controller, routes), obj|
           next if controller.blank?
           next unless allowed_controllers[controller]

           obj[controller] = routes.map do |route|
             action = route.defaults[:action].strip
             action = 'read' if UserAuthorizer::AuthorizeChecker::READ_ACTION.include? action
             action.camelize(:lower)
           end.uniq
    end
  end

  def find_table_columns(role_id)
    table_names = []

    Dir["#{Rails.root}/app/models/**/*.rb"].each do |path|
      filename, dir = path.split('app/models/').last.split('/').reverse
      next if dir == 'concerns'

      filename = filename.gsub(/(\w+)\.rb/, '\1')
      table_name = [dir&.capitalize, filename.classify].compact.join('::')
      next if ['ApplicationRecord', 'ApplicationModel', 'Ipos::ActivityLog'].include?(table_name)

      table_names << table_name
    end
    column_authorizer = Authorizer::ColumnAuthorizer.by_role(role_id)
    table_names.each_with_object({}) do |table_name, obj|
      klass = table_name.constantize
      table_key = table_name.camelize(:lower)
      table_def = Datatable::DefinitionExtractor.new(klass)
      if Role.superadmin?(role_id)
        obj[table_key] = TableColumnSerializer.new(table_def.column_definitions)
        next
      end
      columns = column_authorizer.columns_of_klass(klass)
      next if columns.blank?

      selected_columns = columns.map { |column_name| table_def.column_of(column_name) }
                                .compact
      obj[table_key] = TableColumnSerializer.new(selected_columns)
    end
  end
end
