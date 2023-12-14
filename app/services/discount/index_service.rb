class Discount::IndexService < BaseService
  def execute_service
    extract_params
    @discounts = find_discounts
    render_json(DiscountSerializer.new(discounts,{meta: meta}))
  end

  private

  def meta
    {
      page: @page,
      per: @per,
      total_page: @discounts.total_pages,
    }
  end

  def extract_params
    permitted_params = @params.permit(:page,:per,:search_text)
    @page = permitted_params.fetch(:page,1).to_i
    @per = permitted_params.fetch(:per,20).to_i
    @search_text = permitted_params[:search_text].to_s
  end

  def find_discounts
    discounts = Discount.order(code: :asc)
        .page(@page)
        .per(@per)
    discounts = discounts.where(['code ilike ?',"%#{@search_text}%"]) if @search_text.present?
    discounts
  end
end
