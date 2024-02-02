class Discount::ColumnsService < ApplicationService

  def execute_service
    headers = Discount::TABLE_HEADER
    render_json({data:{
      column_names: headers.map(&:humanize_name),
      column_order: headers
    }})
  end

  private

end
