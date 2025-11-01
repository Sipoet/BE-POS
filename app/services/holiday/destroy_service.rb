class Holiday::DestroyService < ApplicationService
  def execute_service
    holiday = Holiday.find(params[:id])
    raise RecordNotFound.new(params[:id], Holiday.model_name.human) if holiday.nil?

    if holiday.destroy
      render_json({ message: "#{holiday.id} sukses dihapus" })
    else
      render_error_record(holiday)
    end
  end
end
