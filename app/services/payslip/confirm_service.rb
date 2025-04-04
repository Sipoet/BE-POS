class Payslip::ConfirmService < ApplicationService

  def execute_service
    payslip = Payslip.find(params[:id])
    raise RecordNotFound.new(params[:id],Payslip.model_name.human) if payslip.nil?
    payslip.update!(status: :confirmed)
    render_json({message: 'Sukses confirm'})
  end

  private


end
