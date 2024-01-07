class Discount::ShowService < BaseService
  def execute_service
    discount = Discount.find_by(code: @params[:code])
    raise BaseService::RecordNotFound.new(@params[:code],Discount.name) if discount.nil?
    render_json(DiscountSerializer.new(discount))
  end
end
