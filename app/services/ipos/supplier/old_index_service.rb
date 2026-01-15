class Ipos::Supplier::OldIndexService < ApplicationService
  def execute_service
    text_search = @params[:search_text].to_s
    page = @params.fetch(:page, 1)
    per = @params.fetch(:per, 10)
    suppliers = search_data(text_search)
    suppliers = suppliers.page(page)
                         .per(per)
                         .pluck(:kode, :nama)
                         .map do |(code, name)|
                           { id: code, name: name }
    end
    @controller.render json: { data: suppliers }, status: 200
  end

  private

  def search_data(text_search)
    if text_search.present?
      Ipos::Supplier.where('nama ilike ? or kode ilike ?', "%#{text_search}%", "%#{text_search}%")
    else
      Ipos::Supplier.all
    end
  end
end
