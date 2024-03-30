class Payslip::DestroyService < ApplicationService

  def execute_service
    payslip = Payslip.find( params[:id])
    raise RecordNotFound.new(params[:id],Payslip.model_name.human) if payslip.nil?
    if !payslip.draft?
      render_json({message: 'hanya bisa hapus status draft'}, {status: :conflict})
      return
    end
    if payslip.destroy
      render_json({message: "#{payslip.id} sukses dihapus"})
    else
      render_error_record(payslip)
    end
  end
end
