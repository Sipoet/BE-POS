class Role::ColumnNameService < ApplicationService
  def execute_service
    extract_params
    column_definitions = find_table_columns
    if @page == 1
      render_json({
                    data: column_definitions.map do |column_name|
                      { id: column_name.name, name: column_name.humanize_name }
                    end
                  })
    else
      render_json({ data: [] })
    end
  rescue StandardError => e
    render_json({ message: e.message }, { status: :conflict })
  end

  private

  def extract_params
    permitted_params = params.permit(:search_text, :table_name, page: %i[page limit])
    @search_text = permitted_params[:search_text]
    @table_name = permitted_params[:table_name]
    @page = begin
      permitted_params[:page].fetch(:page, 1).to_i
    rescue StandardError
      1
    end
  end

  def find_table_columns
    return [] if @table_name.blank?

    klass = @table_name.classify.try(:constantize)
    table_definition = Datatable::DefinitionExtractor.new(klass)
    column_definitions = table_definition.column_definitions
    return column_definitions if @search_text.blank?

    downcase_text = @search_text.downcase
    column_definitions.select do |column_definition|
      column_definition.humanize_name&.downcase&.include?(downcase_text)
    end
  end
end
