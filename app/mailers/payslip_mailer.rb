class PayslipMailer < ApplicationMailer

  def employee_payslip
    payslip_id = params[:payslip_id]
    @payslip = Payslip.find(payslip_id)
    @employee =  @payslip.employee
    return if @employee.email.blank?
    @cc_email = Setting.get('cc_email')
    @bcc_email = Setting.get('bcc_email')
    @period_desc = @payslip.end_date.strftime('%m%y')
    file_password = @employee.id_number[-6..-1] rescue nil
    attachments["slip_gaji.pdf"] = generate_payslip(@payslip,{file_password: file_password})
    mail(
      to:  @employee.email,
      subject: "Slip Gaji #{@employee.name} #{@period_desc}",
      bcc: @bcc_email,
      cc: @cc_email)
  end

  private
  def generate_payslip(payslip,options = {})
    PayslipPdfGenerator.run!(payslip,options)
  end
end
