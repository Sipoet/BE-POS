class Discount::RefreshActivePromotionService < BaseService

  def execute_service
    jid = RefreshActivePromotionJob.perform_async
    render_json({data:{jid: jid}})
  end

  private

end
