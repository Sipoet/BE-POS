class ItemType::IndexService < BaseService
  def execute_service
    text_search = @params[:query].to_s
    page = @params.fetch(:page,1)
    per =@params.fetch(:per,10)
    item_types = search_data(text_search)
    item_types = item_types.page(page)
                          .per(per)
                          .pluck(:jenis,:ketjenis)
                          .map do|(type,description)|
      {id: type, name: "#{type}-#{description}"}
    end
    @controller.render json: {data: item_types}, status: 200
  end

  private

  def search_data(text_search)
    puts text_search
    if text_search.present?
      ItemType.where('jenis ilike ? or ketjenis ilike ?', "%#{text_search}%", "%#{text_search}%")
    else
      ItemType.all
    end
  end
end