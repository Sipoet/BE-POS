class Discount::CreateService < BaseService
  def execute_service
    permitted_params = @params.required(:discount)
                              .permit(:item_code, :supplier_code, :item_type, :brand_name, :discount1, :discount2,:discount3,:discount4,:start_time, :end_time)
    discount = Discount.new(permitted_params)
    discount.code = generate_code(discount)
    if discount.save
      RefreshPromotionJob.perform_async(discount.id)
      render_json(DiscountSerializer.new(discount))
    else
      render_json({message: 'gagal disimpan',errors: discount.errors.full_messages},{status: :conflict})
    end
  end

  def generate_code(discount)
    [
      discount.item_code,
      discount.supplier_code,
      discount.item_type,
      discount.brand_name,
      discount.end_time.try(:strftime,'%b%y')
    ].compact.join('-')
  end
end
