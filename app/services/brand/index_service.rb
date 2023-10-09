class Brand::IndexService < BaseService
  def execute_service
    text_search = @params[:query].to_s
    page = @params.fetch(:page,1)
    per =@params.fetch(:per,10)
    brands = search_data(text_search)
    brands = brands.page(page)
                   .per(per)
                   .pluck(:merek)
                   .map do|brand_name|
      {id: brand_name, name: brand_name}
    end
    @controller.render json: {data: brands}, status: 200
  end

  private

  def search_data(text_search)
    if text_search.present?
      Brand.where('merek ilike ?', "%#{text_search}%")
    else
      Brand.all
    end
  end
end
