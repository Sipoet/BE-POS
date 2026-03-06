# frozen_string_literal: true

class Ipos::ItemStock::UpdateService < ApplicationService
  def execute_service
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(:item_code, :location_code)
    item_stock = Ipos::ItemStock.find_by(item_code: permitted_params[:item_code],
                                         location_code: permitted_params[:location_code])
    if item_stock.nil?
      raise RecordNotFound.new("#{permitted_params[:item_code]}-#{permitted_params[:location_code]}",
                               Ipos::ItemStock.model_name.human)
    end

    if record_save?(item_stock)
      render_json(Ipos::ItemStockSerializer.new(item_stock))
    else
      render_error_record(item_stock)
    end
  end

  def record_save?(item_stock)
    ApplicationRecord.transaction do
      update_attribute(item_stock)
      item_stock.save!
    end
    true
  rescue StandardError => e
    Rails.logger.error e.message
    Rails.logger.error e.backtrace
    false
  end

  def update_attribute(item_stock)
    permitted_params = params.required(:data)
                             .required(:attributes)
                             .permit(:rack)
    item_stock.attributes = permitted_params
  end
end
