class RefreshAllPromotionJob < ApplicationJob
  sidekiq_options queue: 'default', retry: false

  def perform
    dont_run_in_parallel! do
      ApplicationRecord.transaction do
        Discount.all.pluck(:id).each do |id|
          check_if_cancelled!
          RefreshPromotionJob.perform_sync(id)
        end
      end
    end
  rescue JobCancelled => e
    debug_log "job #{jid} cancelled safely"
  end
end
