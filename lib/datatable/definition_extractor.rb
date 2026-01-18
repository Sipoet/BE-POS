class Datatable::DefinitionExtractor
  attr_reader :column_names

  def initialize(model_class)
    @model_class = model_class
    @column_names = []
    begin
      raw_yml = read_definition(model_class)
      @column_definitions = convert_to_column_definitions(raw_yml)
    rescue Errno::ENOENT
      @column_definitions = {}
      # rescue StandardError
      #   @column_definitions = {}
    end
  end

  def column_definitions
    @column_definitions.values
  end

  def column_of(key)
    @column_definitions[key.to_sym]
  end

  def allowed_filter_column_names
    @column_definitions.values.select(&:can_filter).each_with_object([]) do |column, result|
      result << column.name.to_s
      result << column.alias_name if column.alias_name.present?
    end
  end

  def allowed_sort_columns
    @column_definitions.values.select(&:can_sort).map(&:name)
  end

  def allowed_edit_columns
    @column_definitions.values.select(&:can_edit).map { |column| column.edit_key&.to_sym }
  end

  private

  def convert_to_column_definitions(raw_yml)
    result = {}
    association_class = {}
    if @model_class <= ActiveRecord::Base
      association_class = @model_class.reflect_on_all_associations.each_with_object({}) do |detail, obj|
        class_name = detail.options[:class_name] || detail.name.to_s.classify
        obj[detail.name.to_sym] = class_name
        fk_key = detail.options[:foreign_key]
        obj[fk_key.to_sym] = class_name if fk_key.present?
      end
    end
    raw_yml[:columns].map do |key, options|
      options[:humanize_name] = @model_class.human_attribute_name(key)
      options[:class_name] ||= association_class[key]
      @column_names << key
      result[key.to_sym] = Datatable::TableColumn.new(key, options, @model_class)
      alias_name = result[key].alias_name

      result[alias_name.to_sym] = result[key] if alias_name.present?
    end
    result
  end

  def read_definition(model_class)
    table_def = model_class.name.gsub('::', '/').underscore
    YAML.safe_load_file("#{Rails.root}/app/table_definitions/#{table_def}.yml")
        .deep_symbolize_keys!
  end
end
