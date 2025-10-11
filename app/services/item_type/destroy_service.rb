class ItemType::DestroyService < ApplicationService

  def execute_service
    item_type = Ipos::ItemType.find( params[:code])
    raise RecordNotFound.new(params[:code],Ipos::ItemType.model_name.human) if item_type.nil?
    if item_type.destroy
      render_json({message: "#{item_type.id} sukses dihapus"})
    else
      render_error_record(item_type)
    end
  rescue => e
    render_json({message: e.message,errors:[e.message]},{status: :conflict})
  end
end
