class PayrollType::DestroyService < ApplicationService
  def execute_service
    payroll_type = PayrollType.find(params[:id])
    raise RecordNotFound.new(params[:id], PayrollType.model_name.human) if payroll_type.nil?

    if payroll_type.destroy
      render_json({ message: "#{payroll_type.id} sukses dihapus" })
    else
      render_error_record(payroll_type)
    end
  end
end
