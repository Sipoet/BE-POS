class Role < ApplicationRecord
  TABLE_HEADER = [
    datatable_column(self,:name, :string),
  ]
  SUPERADMIN = 'SUPERADMIN'.freeze

  has_many :column_authorizes, dependent: :destroy
  has_many :access_authorizes, dependent: :destroy
  accepts_nested_attributes_for :column_authorizes, :access_authorizes, allow_destroy: true
end
