class Discount::RefreshPromotionService < ApplicationService
  def execute_service
    discount = Discount.find(@params[:id])
    raise ApplicationService::RecordNotFound if discount.nil?

    jid = RefreshPromotionJob.perform_async(discount.id)
    render_json({
                  data: { jid: jid }
                }, { status: :accepted })
  end
end
