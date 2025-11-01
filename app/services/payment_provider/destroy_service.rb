class PaymentProvider::DestroyService < ApplicationService
  def execute_service
    payment_provider = PaymentProvider.find(params[:id])
    raise RecordNotFound.new(params[:id], PaymentProvider.model_name.human) if payment_provider.nil?

    if payment_provider.destroy
      render_json({ message: "#{payment_provider.id} sukses dihapus" })
    else
      render_error_record(payment_provider)
    end
  end
end
