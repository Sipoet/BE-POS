class RefreshAllPromotionJob < ApplicationJob
  sidekiq_options queue: 'low', retry: false

  def perform
    dont_run_in_parallel! do
      ApplicationRecord.transaction do
        Discount.all.pluck(:id).each do |id|
          check_if_cancelled!
          RefreshPromotionJob.new.perform(id)
        end
      end
    end
  rescue JobCancelled => e
    debug_log "job #{jid} cancelled safely"
  end
end
