class Item::DownloadService < ApplicationService

  def execute_service
    extract_params
    items = find_items
    render_json(Ipos::ItemSerializer.new(items,{fields:{item:[:code,:name,:sell_price,:barcode,:updated_at]}}))
  end
  private

  def find_items
    query = Ipos::Item.all
    if @last_updated_at.present?
      query = query.where(updated_at: @last_updated_at..)
    end
    query
  end

  def extract_params
    @last_updated_at = DateTime.parse(params['last_updated_at']) rescue nil
  end
end
