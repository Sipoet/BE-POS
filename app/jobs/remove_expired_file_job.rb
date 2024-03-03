class RemoveExpiredFileJob < ApplicationJob
  sidekiq_options queue: 'low'

  def perform
    FileStore.expired_today.delete_all
  end
end
