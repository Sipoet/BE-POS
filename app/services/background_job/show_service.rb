class BackgroundJob::ShowService < ApplicationService
  require 'sidekiq/api'
  def execute_service
    job = Sidekiq::Queue.new.find_job(params[:id])
    if job.blank?
      render_not_found_json(record_type: 'background job',record_id: params[:id])
    else
      render_json job
    end
  end

end
