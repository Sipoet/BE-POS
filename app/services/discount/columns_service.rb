class Discount::ColumnsService < ApplicationService

  def execute_service
    table_definitions = Datatable::DefinitionExtractor.new(EdcSettlement)
    headers = table_definitions.column_definitions
    render_json({data:{
      column_names: headers.map(&:humanize_name),
      column_order: headers
    }})
  end

  private

end
