class ItemReport::ColumnsService < ApplicationService

  def execute_service
    table_definitions = Datatable::DefinitionExtractor.new(target_class)
    headers = table_definitions.table_definitions
    render_json({data:{
      column_names: headers.map(&:humanize_name),
      column_order: headers
    }})
  end

  private

end
