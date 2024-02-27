class Item::OldIndexService < ApplicationService
  def execute_service
    search_text = @params[:search_text].to_s
    page = @params.fetch(:page,1)
    per =@params.fetch(:per,10)
    items = search_data(search_text)
    items = items.page(page)
                          .per(per)
                          .pluck(:kodeitem,:namaitem)
                          .map do|(code,name)|
      {id: code, name: "#{code} - #{name}"}
    end
    @controller.render json: {data: items}, status: 200
  end

  private

  def search_data(search_text)
    if search_text.present?
      Ipos::Item.where('kodeitem ilike ? or namaitem ilike ?', "%#{search_text}%", "%#{text_search}%")
    else
      Ipos::Item.all
    end
  end
end
