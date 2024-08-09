class RefreshAllPromotionJob < ApplicationJob
  sidekiq_options queue: 'default', retry: false

  def perform
    dont_run_in_parallel! do
      ApplicationRecord.transaction do
        Discount.all.order(weight: :asc).each do |discount|
          check_if_cancelled!
          Discount::RefreshPromotion.new(discount).refresh!
        end
      end
    end
  rescue JobCancelled => e
    debug_log "job #{jid} cancelled safely"
  end
end
