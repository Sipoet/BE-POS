class CreateTodayCashierSessionJob < ApplicationJob
  sidekiq_options queue: 'default', retry: 2

  def perform
    CashierSession.find_or_create_by(date: Date.today)
  end
end
