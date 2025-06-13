class BackgroundJob::DestroyService < ApplicationService
  require 'sidekiq/api'
  def execute_service
    job = Sidekiq::ScheduledSet.new.find_job(params[:id])
    job = Sidekiq::DeadSet.new.find_job(params[:id]) if job.blank?
    if job.blank?
      raise ApplicationService::RecordNotFound.new(record_type: 'background job',record_id: params[:id])
    end
    if job.delete
      render_json({message: "sukses hapus background job #{job.jid}"})
    else
      render_json({message: "gagal hapus background job #{job.jid}"}, {status: :conflict})
    end
  end

end
