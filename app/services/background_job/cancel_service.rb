class BackgroundJob::CancelService < ApplicationService
  def execute_service
    job = Sidekiq::Queue.new.find_job(params[:id])
    job = Sidekiq::DeadSet.new.find_job(params[:id]) if job.blank?
    raise ApplicationService::RecordNotFound('BackgroundJob', params[:id]) if job.blank?

    ApplicationJob.cancel!(params[:id])
    render_json({ data: job }, { status: :ok })
  end
end
