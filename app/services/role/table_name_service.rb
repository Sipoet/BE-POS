class Role::TableNameService < ApplicationService
  def execute_service
    extract_params
    if @page != 1
      render_json({
                    data: []
                  })
      return
    end
    table_names = []

    Dir["#{Rails.root}/app/models/*.rb"].each do |path|
      table_name = path.split('/').last
      table_name = table_name.gsub(/(\w+)\.rb/, '\1')
      next if %w[application_record application_model].include?(table_name)

      if @search_text.present? && table_name.include?(@search_text)
        table_names << table_name
      elsif @search_text.blank?
        table_names << table_name
      end
    end
    render_json({
                  data: table_names.map { |table_name| { id: table_name, name: table_name } }
                })
  end

  private

  def extract_params
    permitted_params = params.permit(:search_text, page: %i[page limit])
    @search_text = permitted_params[:search_text]
    @page = begin
      permitted_params[:page].fetch(:page, 1).to_i
    rescue StandardError
      1
    end
  end
end
