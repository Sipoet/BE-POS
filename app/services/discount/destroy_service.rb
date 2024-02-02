require 'sidekiq/api'
class Discount::DestroyService < ApplicationService

  def execute_service
    discount = Discount.find(@params[:id])
    raise ApplicationService::RecordNotFound.new(@params[:id],Discount.name) if discount.nil?
    try_stop_background_job(discount)
    begin
      Discount.transaction do
        discount.delete_promotion
        discount.destroy!
      end
      render_json({message: "#{discount.code} sukses dihapus"})
    rescue => e
      Rails.logger.debug e.message
      render_error_record(discount)
    end
  end

  private

  def try_stop_background_job(discount)
    queues = Sidekiq::Queue.all
    queues.each do |queue|
      queue.each do |job|
        if job.klass == 'RefreshPromotionJob' && job.args[0] == discount.id
          job.delete
        end
      end
    end

    workers = Sidekiq::Workers.new
    workers.each do |process_id, thread_id, work|
      work_payload = JSON.parse(work['payload'])
      if work_payload['class'] == 'RefreshPromotionJob' && work_payload['args'][0] == discount.id
        RefreshPromotionJob.cancel!(work_payload['jid'])
      end
    end
  end

end
