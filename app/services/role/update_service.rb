class Role::UpdateService < ApplicationService
  include NestedAttributesMatchup
  def execute_service
    role = Role.find(params[:id])
    raise RecordNotFound.new(params[:id], Role.model_name.human) if role.nil?

    if record_save?(role)
      render_json(RoleSerializer.new(role, { include: %i[access_authorizes role_work_schedules column_authorizes] }))
    else
      render_error_record(role)
    end
  end

  private

  def record_save?(role)
    ApplicationRecord.transaction do
      build_schedule(role)
      update_access_authorizes(role)
      update_column_authorizes(role)
      update_attribute(role)
      delete_cache(role)
      role.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def delete_cache(role)
    Cache.delete_namespace("role-#{role.id}")
  end

  def update_access_authorizes(role)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:access_authorizes)
                             .permit(data: [:type, :id, { attributes: %i[controller action] }])
    return if permitted_params.blank? || permitted_params[:data].blank?

    role.access_authorizes.map(&:mark_for_destruction)
    permitted_params[:data].each do |line_params|
      actions = begin
        line_params[:attributes][:action].split(',')
      rescue StandardError
        []
      end
      actions.each do |action|
        role.access_authorizes.build(
          controller: line_params[:attributes][:controller],
          action: action
        )
      end
    end
  end

  def build_schedule(role)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:role_work_schedules)
                             .permit(data: [:type, :id, { attributes: %i[group_name begin_active_at
                                                                         end_active_at level shift begin_work end_work
                                                                         is_flexible day_of_week] }])
    return if permitted_params.blank? || permitted_params[:data].blank?

    edit_attributes(permitted_params[:data], role.role_work_schedules)
  end

  def update_column_authorizes(role)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:column_authorizes)
                             .permit(data: [:type, :id, { attributes: %i[table column] }])
    return if permitted_params.blank? || permitted_params[:data].blank?

    role.column_authorizes.map(&:mark_for_destruction)
    permitted_params[:data].each do |line_params|
      columns = begin
        line_params[:attributes][:column].split(',')
      rescue StandardError
        []
      end
      columns.each do |column|
        role.column_authorizes.build(
          table: line_params[:attributes][:table],
          column: column
        )
      end
    end
  end

  def update_attribute(role)
    table_definitions = Datatable::DefinitionExtractor.new(Role)
    allowed_columns = table_definitions.column_names
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(allowed_columns)
    role.attributes = permitted_params
  end
end
