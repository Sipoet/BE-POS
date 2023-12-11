class Discount::UpdateService < BaseService
  def execute_service
    permitted_params = @params.required(:discount)
                              .permit(:item_code, :supplier_code, :item_type, :brand_name, :discount1, :discount2,:discount3,:discount4, :start_time, :end_time)
    discount = Discount.find_by(code: @params[:code])
    raise BaseService::RecordNotFound if discount.nil?
    if discount.update(permitted_params)
      RefreshPromotionJob.perform_async(discount.id)
      render_json(DiscountSerializer.new(discount.reload))
    else
      render_json({message: 'gagal disimpan',errors: discount.errors.full_messages},{status: :conflict})
    end
  end
end
