class Role::UpdateService < ApplicationService

  def execute_service
    role = Role.find(params[:id])
    raise RecordNotFound.new(params[:id],Role.model_name.human) if role.nil?
    if record_save?(role)
      render_json(RoleSerializer.new(role,{include: [:access_authorizes,:role_work_schedules,:column_authorizes]}))
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
      role.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def update_access_authorizes(role)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:access_authorizes)
                              .permit(data:[:type,:id, attributes:[:controller, :action]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    role.access_authorizes.map(&:mark_for_destruction)
    permitted_params[:data].each do |line_params|
      actions = line_params[:attributes][:action].split(',') rescue []
      actions.each do |action|
        role.access_authorizes.build(
          controller: line_params[:attributes][:controller],
          action: action)
      end
    end
  end

  def build_schedule(role)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:role_work_schedules)
                              .permit(data:[:type, :id, attributes:[:group_name, :begin_active_at,
                                :end_active_at, :level, :shift, :begin_work, :end_work,
                                :is_flexible, :day_of_week]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    role_work_schedules = role.role_work_schedules.index_by(&:id)
    permitted_params[:data].each do |line_params|
      work_schedule = role_work_schedules[line_params[:id].to_i]
      if work_schedule.present?
        work_schedule.attributes = line_params[:attributes]
        role_work_schedules.delete(line_params[:id])
      else
        work_schedule = role.role_work_schedules.build(line_params[:attributes])
      end
    end
    role_work_schedules.values.map(&:mark_for_destruction)
  end

  def update_column_authorizes(role)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:column_authorizes)
                              .permit(data:[:type,:id, attributes:[:table, :column]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    role.column_authorizes.map(&:mark_for_destruction)
    permitted_params[:data].each do |line_params|
      columns = line_params[:attributes][:column].split(',') rescue []
      columns.each do |column|
        role.column_authorizes.build(
          table: line_params[:attributes][:table],
          column: column)
      end
    end
  end

  def update_attribute(role)
    allowed_columns = Role::TABLE_HEADER.map(&:name)
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    role.attributes = permitted_params
  end
end
