class Discount::IndexService < BaseService
  def execute_service
    extract_params
    discounts = find_discounts
    render_json(DiscountSerializer.new(discounts,{meta: meta}))
  end

  private

  def meta
    {
      page: @page,
      per: @per
    }
  end

  def extract_params
    permitted_params = @params.permit(:page,:per,:text_search)
    @page = permitted_params.fetch(:page,1).to_i
    @per = permitted_params.fetch(:per,20).to_i
    @text_search = permitted_params[:text_search].to_s
  end

  def find_discounts
    Discount.where(['code ilike ?',"%#{@text_search}%"])
        .page(@page)
        .per(@per)
  end
end
