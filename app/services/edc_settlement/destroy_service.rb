class EdcSettlement::DestroyService < ApplicationService
  def execute_service
    edc_settlement = EdcSettlement.find(params[:id])
    raise RecordNotFound.new(params[:id], EdcSettlement.model_name.human) if edc_settlement.nil?

    if edc_settlement.destroy
      render_json({ message: "#{edc_settlement.id} sukses dihapus" })
    else
      render_error_record(edc_settlement)
    end
  end
end
