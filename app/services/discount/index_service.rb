class Discount::IndexService < ApplicationService
  def execute_service
    extract_params
    @discounts = find_discounts
    render_json(DiscountSerializer.new(@discounts,{meta: meta}))
  end

  private

  def meta
    {
      page: @page,
      per: @per,
      total_pages: @discounts.total_pages,
    }
  end

  def extract_params
    permitted_params = @params.permit(:page,:per,:search_text,:order_key,:is_order_asc)
    @page = permitted_params.fetch(:page,1).to_i
    @per = permitted_params.fetch(:per,20).to_i
    @search_text = permitted_params[:search_text].to_s
    @order_key = permitted_params[:order_key] if Discount::TABLE_HEADER.map(&:name).include?(permitted_params[:order_key])
    @order_value = permitted_params[:is_order_asc].try(:downcase) == 'true' ? :asc : :desc
  end

  def find_discounts
    discounts = Discount.all
      .page(@page)
      .per(@per)
    if @search_text.present?
      discounts = discounts.where(['code ilike ? or item_code ilike ? or item_type_name ilike ? or supplier_code ilike ? or brand_name ilike ?']+ Array.new(5,"%#{@search_text}%"))
    end
    if @order_key.present?
      discounts = discounts.order(@order_key => @order_value)
    else
      discounts = discounts.order(code: :asc)
    end
    discounts
  end
end
