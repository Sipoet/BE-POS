class Supplier::IndexService < BaseService
  def execute_service
    text_search = @params[:query].to_s
    page = @params.fetch(:page,1)
    per =@params.fetch(:per,10)
    suppliers = search_data(text_search)
    suppliers = suppliers.page(page)
                          .per(per)
                        .pluck(:kode,:nama)
                          .map do|(code,name)|
      {id: code, name: name}
    end
    @controller.render json: {data: suppliers}, status: 200
  end

  private

  def search_data(text_search)
    puts text_search
    if text_search.present?
      Supplier.where('nama ilike ? or kode ilike ?', "%#{text_search}%", "%#{text_search}%")
    else
      Supplier.all
    end
  end
end