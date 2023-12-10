class Discount::CreateService < BaseService
  def execute_service
    permitted_params = @params.required(:discount)
                              .permit(:item_code, :supplier_code, :item_type, :brand_name, :discount1, :discount2,:discount3,:discount4,:code, :start_time, :end_time)
    discount = Discount.new(permitted_params)
    if discount.save
      render_json(DiscountSerializer.new(discount))
    else
      render_json({message: 'gagal disimpan',errors: discount.errors.full_messages},{status: :conflict})
    end
  end
end
