class Discount::RefreshPromotionService < BaseService
  def execute_service
    discount = Discount.find_by(code: @params[:code].to_s)
    raise BaseService::RecordNotFound if discount.nil?
    jid = RefreshPromotionJob.perform_async(discount.id)
    render_json({
      data: {jid: jid}
    },{status: :accepted})
  end
end
