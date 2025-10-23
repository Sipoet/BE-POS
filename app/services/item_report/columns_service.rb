class ItemReport::ColumnsService < ApplicationService
  def execute_service
    table_definition = Datatable::DefinitionExtractor.new(target_class)
    headers = table_definition.table_definition
    render_json({ data: {
                  column_names: headers.map(&:humanize_name),
                  column_order: headers
                } })
  end
end
