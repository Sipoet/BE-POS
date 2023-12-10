class Discount::ShowService < BaseService
  def execute_service
    discount = Discount.find_by(code: @params[:code])
    raise BaseService::RecordNotFound if discount.nil?
    render_json(DiscountSerializer.new(discount))
  end
end
