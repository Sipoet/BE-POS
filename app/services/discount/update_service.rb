require 'sidekiq/api'
class Discount::UpdateService < BaseService
  def execute_service
    permitted_params = @params.required(:discount)
                              .permit(:item_code, :supplier_code, :item_type_name, :brand_name, :discount1, :discount2,:discount3,:discount4, :start_time, :end_time)
    discount = Discount.find(@params[:id])
    raise BaseService::RecordNotFound.new(@params[:code],Discount.name) if discount.nil?
    if discount.update(permitted_params)
      try_stop_background_job(discount)
      RefreshPromotionJob.perform_async(discount.id)
      render_json(DiscountSerializer.new(discount.reload))
    else
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
