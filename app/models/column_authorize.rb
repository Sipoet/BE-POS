class ColumnAuthorize < ApplicationRecord

  validates :table, presence: true
  validates :column, presence: true
  validate :valid_column

  belongs_to :role

  private
  def valid_column
    return if  table.blank?
    klass = table.classify.constantize
    if klass::TABLE_HEADER.map(&:name).include?(column)
      errors.add(:column,:inclusion)
    end
  end
end
