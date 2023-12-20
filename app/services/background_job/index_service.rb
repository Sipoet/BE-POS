class BackgroundJob::IndexService < BaseService
  require 'sidekiq/api'

  def execute_service
    scheduled_jobs = Sidekiq::ScheduledSet.new.map{|job| decorate job}
    progress_jobs = Sidekiq::ProcessSet.new.map{|job| decorate job}
    dead_jobs = Sidekiq::DeadSet.new.map{|job| decorate job}
    retried_jobs = Sidekiq::RetrySet.new.map{|job| decorate job}
    Sidekiq::RetrySet.new
    render_json({data: {
      scheduled_jobs: scheduled_jobs,
      progress_jobs: progress_jobs,
      dead_jobs: dead_jobs,
      retried_jobs: retried_jobs
    }})
  end
  private

  def decorate(job)
    id = job.try(:identity) || job.try(:jid)
    klass = job.try(:klass)
    args = job.try(:args)
    {
      id: id,
      attributes: {
        class: klass,
        args: args
      }
    }
  end
end
