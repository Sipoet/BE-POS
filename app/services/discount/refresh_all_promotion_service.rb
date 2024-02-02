class Discount::RefreshAllPromotionService < ApplicationService
  def execute_service
    discount_ids = Discount.all
                           .pluck(:id)
                           .map{|id|[id]}
    jid = RefreshPromotionJob.perform_bulk(discount_ids)
    render_json({
      data: {jid: jid}
    },{status: :accepted})
  end
end
