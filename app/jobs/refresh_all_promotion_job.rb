# frozen_string_literal: true

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
  rescue JobCancelled
    debug_log "job #{jid} cancelled safely"
  end
end
