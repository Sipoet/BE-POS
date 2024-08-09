class RefreshPromotionJob < ApplicationJob
  sidekiq_options queue: 'default', retry: 2
  IPOS_MAX_ITEM_PER_PROMOTION = 200
  def perform(id)
    check_if_cancelled!
    discount = Discount.find(id)
    Discount::RefreshPromotion.new(discount).refresh!
  rescue JobCancelled => e
    debug_log "job #{jid} cancelled safely"
  end

end
