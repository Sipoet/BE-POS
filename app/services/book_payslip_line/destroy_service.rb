class BookPayslipLine::DestroyService < ApplicationService

  def execute_service
    book_payslip_line = BookPayslipLine.find( params[:id])
    raise RecordNotFound.new(params[:id],BookPayslipLine.model_name.human) if book_payslip_line.nil?
    if book_payslip_line.destroy
      render_json({message: "#{book_payslip_line.id} sukses dihapus"})
    else
      render_error_record(book_payslip_line)
    end
  end
end
