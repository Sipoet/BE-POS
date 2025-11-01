class ColumnAuthorize < ApplicationRecord
  validates :table, presence: true
  validates :column, presence: true
  validate :valid_column

  belongs_to :role

  private

  def valid_column
    return if table.blank?

    klass = table.classify.constantize
    table_definitions = Datatable::DefinitionExtractor.new(klass)
    return unless table_definitions.column_names.include?(column)

    errors.add(:column, :inclusion)
  end
end
