class Role::CreateService < ApplicationService

  def execute_service
    role = Role.new
    if record_save?(role)
      render_json(RoleSerializer.new(role),{status: :created})
    else
      render_error_record(role)
    end
  end

  def record_save?(role)
    ApplicationRecord.transaction do
      update_access_authorizes(role)
      update_column_authorizes(role)
      update_attribute(role)
      role.save!
    end
    return true
  rescue => e
    Rails.logger.errors e.message
    Rails.logger.errors e.backtrace
    return false
  end

  def update_access_authorizes(role)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:access_authorizes)
                              .permit(data:[:type,:id, attributes:[:controller, :action]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    permitted_params[:data].each do |line_params|
      role.access_authorizes.build(line_params[:attributes])
    end
  end

  def update_column_authorizes(role)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:column_authorizes)
                              .permit(data:[:type,:id, attributes:[:table, :column]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    permitted_params[:data].each do |line_params|
      role.column_authorizes.build(line_params[:attributes])
    end
  end

  def update_attribute(role)
    allowed_columns = Role::TABLE_HEADER.map(&:key)
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    role.attributes = permitted_params
  end
end
