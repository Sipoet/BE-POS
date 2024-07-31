class PaymentProvider::UpdateService < ApplicationService

  def execute_service
    payment_provider = PaymentProvider.find(params[:id])
    raise RecordNotFound.new(params[:id],PaymentProvider.model_name.human) if payment_provider.nil?
    if record_save?(payment_provider)
      render_json(PaymentProviderSerializer.new(payment_provider,{fields: @fields}))
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
