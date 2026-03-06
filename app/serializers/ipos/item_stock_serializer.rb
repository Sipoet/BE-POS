class Ipos::ItemStockSerializer
  include JSONAPI::Serializer
  attributes :item_code, :location_code, :quantity, :rack

  belongs_to :item, set_id: :item_code, id_method_name: :item_code, serializer: Ipos::ItemSerializer, if: proc { |record, params|
    begin
      params[:include].include?('item')
    rescue StandardError
      false
    end
  }
  belongs_to :location, set_id: :location_code, id_method_name: :location_code, serializer: Ipos::LocationSerializer, if: proc { |record, params|
    begin
      params[:include].include?('location')
    rescue StandardError
      false
    end
  }
end
