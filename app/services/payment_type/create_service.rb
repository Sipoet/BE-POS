class PaymentType::CreateService < ApplicationService

  def execute_service
    payment_type = PaymentType.new
    if record_save?(payment_type)
      render_json(PaymentTypeSerializer.new(payment_type,fields:@fields),{status: :created})
    else
      render_error_record(payment_type)
    end
  end

  def record_save?(payment_type)
    ApplicationRecord.transaction do
      update_attribute(payment_type)
      payment_type.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def update_attribute(payment_type)
    allowed_columns = PaymentType::TABLE_HEADER.map(&:name)
    @fields = {payment_type: allowed_columns}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    payment_type.attributes = permitted_params
  end
end
