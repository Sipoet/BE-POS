class Payslip::SendEmailService < ApplicationService

  def execute_service
    payslip = Payslip.find(params[:id])
    raise RecordNotFound.new(params[:id],Payslip.model_name.human) if payslip.nil?
    if payslip.employee&.email.present?
      send_email(payslip)
      render_json({message:'dalam proses antrian kirim'})
    else
      render_json({message:'email karyawan tidak ada'},{status: :conflict})
    end
  end

  private
  def send_email(payslip)
    PayslipMailer.with(payslip_id: payslip.id)
                  .employee_payslip
                  .deliver_later
  end

end
