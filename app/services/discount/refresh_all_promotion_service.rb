class Discount::RefreshAllPromotionService < BaseService
  def execute_service
    discount_ids = Discount.where(end_time: (DateTime.now)..)
                           .pluck(:id)
    list_jobs = []
    jid = RefreshPromotionJob.perform_bulk(discount_ids)

    render_json({
      data: {jid: jid}
    })
  end
end
