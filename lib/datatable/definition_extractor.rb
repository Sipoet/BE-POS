class Datatable::DefinitionExtractor

  def initialize(record_class)
    @record_class = record_class
    @columns_hash = record_class.columns_hash
  end

  def extract_column(columns)
    raise 'is not array' if !columns.is_a?(Array)
    columns.map do |key|
      Datatable::TableColumn.new(
        name: key,
        type: column_type_of(key),
        humanize_name: @record_class.human_attribute_name(key)
      )
    end
  end

  private

  def column_type_of(key)
    @columns_hash[key].sql_type_metadata.type rescue nil
  end
end
