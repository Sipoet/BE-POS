class Discount::ColumnsService < BaseService

  def execute_service
    headers = Discount::TABLE_HEADER
    render_json({data:{
      column_names: localized_column_names(headers),
      column_order: headers
    }})
  end

  private

  def localized_column_names(headers)
    headers.map{|column_name| Discount.human_attribute_name(column_name)}
  end
end
