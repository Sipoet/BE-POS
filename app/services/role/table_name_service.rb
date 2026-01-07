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

      klass = table_name.classify.constantize
      humanize_name = klass.model_name.human
      if include_table?(@search_text, humanize_name)
        table_names << Result.new(id: klass.try(:table_name) || table_name, name: humanize_name)
      end
    end
    Dir["#{Rails.root}/app/models/ipos/*.rb"].each do |path|
      table_name = path.split('/').last
      table_name = table_name.gsub(/(\w+)\.rb/, '\1')

      next if %w[application_record application_model].include?(table_name)

      klass = "Ipos::#{table_name.classify}".constantize
      humanize_name = klass.model_name.human
      table_names << Result.new(id: "Ipos::#{table_name.classify}", name: humanize_name) if include_table?(
        @search_text, humanize_name
      )
    end
    render_json({
                  data: table_names
                })
  end

  private

  def include_table?(search_text, humanize_name)
    search_text.blank? || (search_text.present? && humanize_name.downcase.include?(search_text.downcase))
  end

  def extract_params
    permitted_params = params.permit(:search_text, page: %i[page limit])
    @search_text = permitted_params[:search_text]
    @page = begin
      permitted_params[:page].fetch(:page, 1).to_i
    rescue StandardError
      1
    end
  end

  class Result
    attr_accessor :id, :name

    def initialize(values)
      @id = values[:id]
      @name = values[:name]
    end

    def label
      name
    end
  end
end
