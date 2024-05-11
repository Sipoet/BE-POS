class Discount::CreateService < ApplicationService
  def execute_service
    permitted_params = @params.required(:data)
                              .required(:attributes)
                              .permit(:code,:weight,:calculation_type, :discount_type,
                              :week1, :week2, :week3, :week4,
                              :week5, :week6, :week7,
                              :discount1, :discount2,:discount3,
                              :discount4, :start_time, :end_time)
    discount = Discount.new(permitted_params)
    build_discount_items(discount)
    build_discount_suppliers(discount)
    build_discount_item_types(discount)
    build_discount_brands(discount)
    discount.generate_code if discount.code.blank?
    if discount.save
      RefreshPromotionJob.perform_async(discount.id)
      render_json(DiscountSerializer.new(discount),{status: :created})
    else
      render_error_record(discount)
    end
  end

  private
  def build_discount_items(discount)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:discount_items)
                              .permit(data:[:type,:id, attributes:[:item_code]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    permitted_params[:data].each do |line_params|
      discount.discount_items.build(line_params[:attributes])
    end
  end

  def build_discount_item_types(discount)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:discount_item_types)
                              .permit(data:[:type,:id, attributes:[:item_type_name, :is_exclude]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    permitted_params[:data].each do |line_params|
      discount.discount_item_types.build(line_params[:attributes])
    end
  end

  def build_discount_brands(discount)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:discount_brands)
                              .permit(data:[:type,:id, attributes:[:brand_name, :is_exclude]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    permitted_params[:data].each do |line_params|
      discount.discount_brands.build(line_params[:attributes])
    end
  end

  def build_discount_suppliers(discount)
    permitted_params = params.required(:data)
                              .required(:relationships)
                              .required(:discount_suppliers)
                              .permit(data:[:type,:id, attributes:[:supplier_code, :is_exclude]])
    return if (permitted_params.blank? || permitted_params[:data].blank?)
    permitted_params[:data].each do |line_params|
      discount.discount_suppliers.build(line_params[:attributes])
    end
  end

end
