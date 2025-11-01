require 'sidekiq/api'
class Discount::UpdateService < ApplicationService
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
        build_discount_items(discount)
        build_discount_item_types(discount)
        build_discount_suppliers(discount)
        build_discount_brands(discount)
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

  def build_discount_items(discount)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:discount_items)
                             .permit(data: [:type, :id, { attributes: [:item_code] }])
    return if permitted_params.blank? || permitted_params[:data].blank?

    discount_items = discount.discount_items.index_by(&:id)
    permitted_params[:data].each do |line_params|
      discount_item = discount_items[line_params[:id].to_i]
      if discount_item.present?
        discount_item.attributes = line_params[:attributes]
        discount_items.delete(line_params[:id])
      else
        discount.discount_items.build(line_params[:attributes])
      end
    end
    discount_items.values.map(&:mark_for_destruction)
  end

  def build_discount_item_types(discount)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:discount_item_types)
                             .permit(data: [:type, :id, { attributes: %i[item_type_name is_exclude] }])
    return if permitted_params.blank? || permitted_params[:data].blank?

    discount_item_types = discount.discount_item_types.index_by(&:id)
    permitted_params[:data].each do |line_params|
      discount_item_type = discount_item_types[line_params[:id].to_i]
      if discount_item_type.present?
        discount_item_type.attributes = line_params[:attributes]
        discount_item_types.delete(line_params[:id])
      else
        discount.discount_item_types.build(line_params[:attributes])
      end
    end
    discount_item_types.values.map(&:mark_for_destruction)
  end

  def build_discount_brands(discount)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:discount_brands)
                             .permit(data: [:type, :id, { attributes: %i[brand_name is_exclude] }])
    return if permitted_params.blank? || permitted_params[:data].blank?

    discount_brands = discount.discount_brands.index_by(&:id)
    permitted_params[:data].each do |line_params|
      discount_brand = discount_brands[line_params[:id].to_i]
      if discount_brand.present?
        discount_brand.attributes = line_params[:attributes]
        discount_brands.delete(line_params[:id])
      else
        discount.discount_brands.build(line_params[:attributes])
      end
    end
    discount_brands.values.map(&:mark_for_destruction)
  end

  def build_discount_suppliers(discount)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:discount_suppliers)
                             .permit(data: [:type, :id, { attributes: %i[supplier_code is_exclude] }])
    return if permitted_params.blank? || permitted_params[:data].blank?

    discount_suppliers = discount.discount_suppliers.index_by(&:id)
    permitted_params[:data].each do |line_params|
      discount_supplier = discount_suppliers[line_params[:id].to_i]
      if discount_supplier.present?
        discount_supplier.attributes = line_params[:attributes]
        discount_suppliers.delete(line_params[:id])
      else
        discount.discount_suppliers.build(line_params[:attributes])
      end
    end
    discount_suppliers.values.map(&:mark_for_destruction)
  end
end
