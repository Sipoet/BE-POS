class BackgroundJob::RetryService < BaseService

  def execute_service
    job = Sidekiq::Queue.new.find_job(params[:id])
    if job.blank?
      raise BaseService::RecordNotFound
    end
    job.retry
    render_json {data:job}

  end

end
