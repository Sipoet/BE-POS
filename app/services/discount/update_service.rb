require 'sidekiq/api'
class Discount::UpdateService < ApplicationService
  include NestedAttributesMatchup
  def execute_service
    permitted_params = @params.required(:data)
                              .required(:attributes)
                              .permit(:code, :weight, :calculation_type, :discount_type,
                                      :week1, :week2, :week3, :week4,
                                      :week5, :week6, :week7, :customer_group_code,
                                      :discount1, :discount2, :discount3,
                                      :discount4, :start_time, :end_time)
    discount = Discount.find(@params[:id])
    raise RecordNotFound.new(@params[:id], Discount.model_name.human) if discount.nil?

    begin
      ApplicationRecord.transaction do
        try_stop_background_job(discount)
        build_discount_filters(discount)
        discount.update!(permitted_params)
        RefreshPromotionJob.perform_async(discount.id)
        render_json(DiscountSerializer.new(discount.reload))
      end
    rescue ActiveRecord::RecordInvalid
      render_error_record(discount)
    rescue StandardError => e
      Rails.logger.error e.message
      Rails.logger.error e.backtrace
      render_json({ message: e.message }, { status: :conflict })
    end
  end

  private

  def try_stop_background_job(discount)
    queues = Sidekiq::Queue.all
    queues.each do |queue|
      queue.each do |job|
        job.delete if job.klass == 'RefreshPromotionJob' && job.args[0] == discount.id
      end
    end

    workers = Sidekiq::Workers.new
    workers.each do |_process_id, _thread_id, work|
      work_payload = JSON.parse(work['payload'])
      if work_payload['class'] == 'RefreshPromotionJob' && work_payload['args'][0] == discount.id
        RefreshPromotionJob.cancel!(work_payload['jid'])
      end
    end
  end

  def build_discount_filters(discount)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:discount_filters)
                             .permit(data: [:type, :id, { attributes: %i[value filter_key is_exclude] }])
    return if permitted_params.blank? || permitted_params[:data].blank?

    edit_attributes(permitted_params[:data], discount.discount_filters)
  end
end
