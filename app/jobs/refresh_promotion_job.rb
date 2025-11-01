class RefreshPromotionJob < ApplicationJob
  sidekiq_options queue: 'default', retry: 2

  def perform(id)
    check_if_cancelled!
    discount = Discount.find(id)
    Discount::RefreshPromotion.new(discount).refresh!
  rescue JobCancelled
    debug_log "job #{jid} cancelled safely"
  end
end
