class Role::ColumnNameService < ApplicationService

  def execute_service
    extract_params
    column_names = find_table_columns
    if @page == 1
      render_json({
        data: column_names.map{|column_name|{id: column_name, name: column_name}}
      })
    else
      render_json({data:[]})
    end

  rescue => e
    render_json({message: e.message},{status: :conflict})
  end

  private

  def extract_params
    permitted_params = params.permit(:search_text,:table_name,page:[:page,:limit])
    @search_text = permitted_params[:search_text]
    @table_name = permitted_params[:table_name]
    @page = (permitted_params[:page][:page] || 1).to_i
  end

  def find_table_columns
    return [] if @table_name.blank?
    klass = @table_name.classify.constantize
    table_definitions = Datatable::DefinitionExtractor.new(klass)
    column_names = table_definitions.column_names
    return column_names if @search_text.blank?
    column_names.select{|column_name| column_name.to_s.include?(@search_text)}
  end

end
