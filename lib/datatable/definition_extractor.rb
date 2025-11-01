class Datatable::DefinitionExtractor
  def initialize(model_class)
    @model_class = model_class
    begin
      raw_yml = read_definition(model_class)
      @column_definitions = convert_to_column_definitions(raw_yml)
    rescue StandardError
      @column_definitions = {}
    end
  end

  def column_definitions
    @column_definitions.values
  end

  def column_names
    @column_definitions.keys
  end

  def column_of(key)
    @column_definitions[key.to_sym]
  end

  def allowed_columns
    @column_definitions.values.select(&:can_edit).map(&:filter_key)
  end

  def allowed_edit_columns
    @column_definitions.values.select(&:can_edit).map(&:edit_key)
  end

  private

  def convert_to_column_definitions(raw_yml)
    result = {}
    raw_yml[:columns].map do |key, options|
      options[:humanize_name] = @model_class.human_attribute_name(key)
      result[key] = Datatable::TableColumn.new(key, options)
    end
    result
  end

  def read_definition(model_class)
    table_def = model_class.name.gsub('::', '/').underscore
    YAML.safe_load_file("#{Rails.root}/app/table_definitions/#{table_def}.yml")
        .deep_symbolize_keys!
  end
end
