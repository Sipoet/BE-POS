class PayrollType::CreateService < ApplicationService

  def execute_service
    payroll_type = PayrollType.new
    if record_save?(payroll_type)
      render_json(PayrollTypeSerializer.new(payroll_type,fields:@fields),{status: :created})
    else
      render_error_record(payroll_type)
    end
  end

  def record_save?(payroll_type)
    ApplicationRecord.transaction do
      update_attribute(payroll_type)
      payroll_type.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def update_attribute(payroll_type)
    allowed_columns = PayrollType::TABLE_HEADER.map(&:name)
    @fields = {payroll_type: allowed_columns}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    payroll_type.attributes = permitted_params
  end
end
