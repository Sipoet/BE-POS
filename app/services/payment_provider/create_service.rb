class PaymentProvider::CreateService < ApplicationService

  def execute_service
    payment_provider = PaymentProvider.new
    if record_save?(payment_provider)
      render_json(PaymentProviderSerializer.new(payment_provider,fields:@fields),{status: :created})
    else
      render_error_record(payment_provider)
    end
  end

  def record_save?(payment_provider)
    ApplicationRecord.transaction do
      update_attribute(payment_provider)
      payment_provider.save!
    end
    return true
  rescue => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    return false
  end

  def update_attribute(payment_provider)
    allowed_columns = PaymentProvider::TABLE_HEADER.map(&:name)
    @fields = {payment_provider: allowed_columns}
    permitted_params = params.required(:data)
                              .required(:attributes)
                              .permit(allowed_columns)
    payment_provider.attributes = permitted_params
  end
end
