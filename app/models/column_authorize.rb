class ColumnAuthorize < ApplicationRecord

  validates :table, presence: true
  validates :column, presence: true

  belongs_to :role
end
