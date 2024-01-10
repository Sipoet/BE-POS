class Discount::ShowService < BaseService
  def execute_service
    discount = Discount.find_by(id: @params[:id])
    raise BaseService::RecordNotFound.new(@params[:id],Discount.name) if discount.nil?
    render_json(DiscountSerializer.new(discount))
  end
end
