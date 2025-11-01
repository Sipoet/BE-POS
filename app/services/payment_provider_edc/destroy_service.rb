class PaymentProviderEdc::DestroyService < ApplicationService
  def execute_service
    payment_provider_edc = PaymentProviderEdc.find(params[:id])
    raise RecordNotFound.new(params[:id], PaymentProviderEdc.model_name.human) if payment_provider_edc.nil?

    if payment_provider_edc.destroy
      render_json({ message: "#{payment_provider_edc.id} sukses dihapus" })
    else
      render_error_record(payment_provider_edc)
    end
  end
end
