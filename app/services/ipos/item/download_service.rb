class Ipos::Item::DownloadService < ApplicationService
  def execute_service
    extract_params
    items = find_items
    render_json(Ipos::ItemSerializer.new(items,
                                         { fields: { item: %i[code name sell_price barcode updated_at] } }))
  end

  private

  def find_items
    query = Ipos::Item.all
    query = query.where(updated_at: @last_updated_at..) if @last_updated_at.present?
    query
  end

  def extract_params
    @last_updated_at = begin
      DateTime.parse(params['last_updated_at'])
    rescue StandardError
      nil
    end
  end
end
