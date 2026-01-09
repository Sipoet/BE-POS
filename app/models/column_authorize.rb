class ColumnAuthorize < ApplicationRecord
  validates :table, presence: true
  validates :column, presence: true
  validate :valid_column

  scope :columns_by_role, lambda { |role_id, table_name|
    where(role_id: role_id, table: table_name).pluck(:column)
  }

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
