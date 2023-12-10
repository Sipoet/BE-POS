class Discount::DestroyService < BaseService
  def execute_service
    discount = Discount.find_by(code: @params[:code])
    raise BaseService::RecordNotFound if discount.nil?
    if discount.destroy
      render_json({message: 'sukses dihapus'})
    else
      render_json({message: 'gagal dihapus',errors: discount.errors.full_messages},{status: :conflict})
    end
  end
end
