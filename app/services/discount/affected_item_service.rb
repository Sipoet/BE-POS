# frozen_string_literal: true

class Discount::AffectedItemService < ApplicationService
  include DiscountAffectedItem
  def execute_service
    permitted_params = @params.required(:data)
                              .required(:attributes)
                              .permit(:code, :weight, :calculation_type, :discount_type,
                                      :week1, :week2, :week3, :week4,
                                      :week5, :week6, :week7,
                                      :discount1, :discount2, :discount3,
                                      :customer_group_code,
                                      :discount4, :start_time, :end_time)
    discount = Discount.new(permitted_params)
    build_discount_filters(discount)
    limit = nil

    item_reports = items_based_discount(discount)
    if discount.discount_filters.blank?
      limit = 500
      item_reports = item_reports.page(1).per(limit)
    end
    options = {
      meta: {
        filter: @filter,
        page: 1,
        limit: limit,
        total_pages: 1,
        total_rows: item_reports.count
      },
      fields: { item_report: %i[item_code item_name stock_left warehouse_stock store_stock cogs
                                sell_price margin limit_profit_discount] },
      params: { include: nil },
      include: nil
    }
    render_json(ItemReportSerializer.new(item_reports, options))
  end

  private

  def build_discount_filters(discount)
    permitted_params = params.required(:data)
                             .required(:relationships)
                             .required(:discount_filters)
                             .permit(data: [:type, :id, { attributes: %i[value filter_key is_exclude] }])
    return if permitted_params.blank? || permitted_params[:data].blank?

    permitted_params[:data].each do |line_params|
      discount.discount_filters.build(line_params[:attributes])
    end
  end
end
