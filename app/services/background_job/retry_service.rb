class BackgroundJob::RetryService < ApplicationService

  def execute_service
    job = Sidekiq::Queue.new.find_job(params[:id])
    if job.blank?
      raise ApplicationService::RecordNotFound
    end
    job.retry
    render_json {data:job}

  end

end
