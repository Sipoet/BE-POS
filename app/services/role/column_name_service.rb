class Role::ColumnNameService < ApplicationService

  def execute_service
    column_names = find_table_columns
    render_json({
      data: column_names.map{|column_name|{id: column_name, name: column_name}}
    })
  rescue => e
    render_json({message: e.message},{status: :conflict})
  end

  def find_table_columns
    permitted_params = params.permit(:search_text,:table_name)
    search_text = permitted_params[:search_text]
    table_name = permitted_params[:table_name]
    return [] if table_name.blank?
    klass = table_name.classify.constantize
    column_names = klass::TABLE_HEADER.map(&:name)
    return column_names if search_text.blank?
    column_names.select{|column_name| column_name.to_s.include?(search_text)}
  end

end
