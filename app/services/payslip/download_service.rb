class Payslip::DownloadService < ApplicationService
  def execute_service
    payslip = Payslip.find(params[:id])
    raise RecordNotFound.new(params[:id], Payslip.model_name.human) if payslip.nil?

    pdf_io = generate_pdf(payslip)
    @controller.send_file pdf_io.path, filename: format_name(payslip), type: 'application/pdf'
    pdf_io.close
  end

  private

  def format_name(payslip)
    "Slip Gaji #{payslip.employee.name}-#{payslip.start_date}-#{payslip.end_date}.pdf"
  end

  def generate_pdf(payslip)
    tempfile = Tempfile.new(['generated', format_name(payslip)])
    PayslipPdfGenerator.run!(payslip, file_path: tempfile.path)
    tempfile
  end
end
