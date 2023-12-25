class BackgroundJob::DestroyService < BaseService
  require 'sidekiq/api'
  def execute_service
    job = Sidekiq::Queue.new.find_job(params[:id])
    if job.blank?
      raise BaseService::RecordNotFound.new(record_type: 'background job',record_id: params[:id])
    end
    if job.delete
      render_json({message: "sukses hapus background job #{job.jid}"})
    else
      render_json({message: "gagal hapus background job #{job.jid}"}, {status: :conflict})
    end
  end

end
