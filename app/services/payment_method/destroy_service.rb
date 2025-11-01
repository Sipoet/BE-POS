class PaymentMethod::DestroyService < ApplicationService
  def execute_service
    payment_method = PaymentMethod.find(params[:id])
    raise RecordNotFound.new(params[:id], PaymentMethod.model_name.human) if payment_method.nil?

    if payment_method.destroy
      render_json({ message: "#{payment_method.id} sukses dihapus" })
    else
      render_error_record(payment_method)
    end
  end
end
