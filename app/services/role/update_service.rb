class Role::UpdateService < ApplicationService

  def execute_service
    role = Role.find(params[:id])
    raise RecordNotFound.new(params[:id],Role.model_name.human) if role.nil?
    if record_save?(role)
      render_json(RoleSerializer.new(role))
    else
      render_error_record(role)
    end
  end

  private

  def record_save?(role)
    ApplicationRecord.transaction do
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
