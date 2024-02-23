class Role < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:name, :string),
  ]

  has_many :access_authorizes, dependent: :destroy
  has_many :column_authorizes, dependent: :destroy
end
