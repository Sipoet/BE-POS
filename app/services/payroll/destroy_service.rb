class Payroll::DestroyService < ApplicationService

  def execute_service
    payroll = Payroll.find(params[:id])
    raise RecordNotFound.new(params[:id],Payroll.model_name.human) if payroll.nil?
    if payroll.destroy
      render_json({message: "#{payroll.name} sukses dihapus"})
    else
      render_error_record(payroll)
    end
  end

end
