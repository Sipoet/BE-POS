class Discount::CreateService < BaseService
  def execute_service
    permitted_params = @params.required(:discount)
                              .permit(:item_code, :supplier_code, :item_type_name, :brand_name, :discount1, :discount2,:discount3,:discount4,:start_time, :end_time)
    discount = Discount.new(permitted_params)
    discount.generate_code
    if discount.save
      RefreshPromotionJob.perform_async(discount.id)
      render_json(DiscountSerializer.new(discount),{status: :created})
    else
      render_error_record(discount)
    end
  end

end
