require 'sidekiq/api'
class Discount::UpdateService < ApplicationService
  def execute_service
    permitted_params = @params.required(:discount)
                              .permit(:item_code,:weight,:calculation_type, :supplier_code, :item_type_name,
                                      :brand_name,:blacklist_supplier_code, :blacklist_item_type_name,
                                      :blacklist_brand_name, :discount1, :discount2,:discount3,
                                      :discount4, :start_time, :end_time)
    discount = Discount.find(@params[:id])
    raise ApplicationService::RecordNotFound.new(@params[:id],Discount.name) if discount.nil?
    begin
      ApplicationRecord.transaction do
        try_stop_background_job(discount)
        build_discount_items(discount)
        discount.update!(permitted_params)
        RefreshPromotionJob.perform_async(discount.id)
        render_json(DiscountSerializer.new(discount.reload))
      end
    rescue ActiveRecord::RecordInvalid => e
      render_error_record(discount)
    rescue => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      render_json({message: e.message},{status: :conflict})
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

  def build_discount_items(discount)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:discount_items)
                              .permit(data:[:type,:id, attributes:[:item_code]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    discount_items = discount.discount_items.index_by(&:id)
    permitted_params[:data].each do |line_params|
      discount_item = discount_items[line_params[:id].to_i]
      if discount_item.present?
        discount_item.attributes = line_params[:attributes]
        discount_items.delete(line_params[:id])
      else
        discount_item = discount.discount_items.build(line_params[:attributes])
      end
    end
    discount_items.values.map(&:mark_for_destruction)
  end
end
