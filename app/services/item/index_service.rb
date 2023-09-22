class Item::IndexService < BaseService
  def execute_service
    text_search = @params[:query].to_s
    page = @params.fetch(:page,1)
    per =@params.fetch(:per,10)
    items = search_data(text_search)
    items = items.page(page)
                          .per(per)
                          .pluck(:kodeitem,:namaitem)
                          .map do|(code,name)|
      {id: code, name: name}
    end
    @controller.render json: {data: items}, status: 200
  end

  private

  def search_data(text_search)
    puts text_search
    if text_search.present?
      Item.where('kodeitem ilike ? or namaitem ilike ?', "%#{text_search}%", "%#{text_search}%")
    else
      Item.all
    end
  end
end