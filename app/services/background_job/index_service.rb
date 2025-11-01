class BackgroundJob::IndexService < ApplicationService
  require 'sidekiq/api'

  def execute_service
    scheduled_jobs = Sidekiq::ScheduledSet.new.map { |job| decorate(job, :scheduled) } || []
    workers = Sidekiq::Workers.new.map do |_process_id, _thread_id, worker|
      decorate_worker worker
    end
    dead_jobs = Sidekiq::DeadSet.new.map { |job| decorate(job, :dead) } || []
    retried_jobs = Sidekiq::RetrySet.new.map { |job| decorate(job, :retry) } || []
    render_json({ data: scheduled_jobs + workers + dead_jobs + retried_jobs })
  end

  private

  def decorate(job, status)
    id = job.try(:identity) || job.try(:jid)
    created_at = begin
      Time.at(job.item['created_at'])
    rescue StandardError
      nil
    end
    Rails.logger.debug "==job #{job.inspect}"
    {
      id: id,
      type: 'background_job',
      attributes: {
        job_class: job.try(:klass),
        args: job.try(:args),
        status: status,
        created_at: created_at,
        description: job.try(:value)
      }
    }
  end

  def decorate_worker(worker)
    payload = JSON.parse(worker['payload'], { symbolize_names: true })
    {
      id: payload[:jid],
      type: 'background_job',
      attributes: {
        job_class: payload[:class],
        args: payload[:args],
        status: :process,
        created_at: Time.at(payload[:created_at]),
        description: payload.except(:jid, :class, :args, :created_at)
      }
    }
  end
end
