class Role < ApplicationRecord
  has_paper_trail
  TABLE_HEADER = [
    datatable_column(self,:name, :string),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ]
  SUPERADMIN = 'SUPERADMIN'.freeze

  has_many :column_authorizes, dependent: :destroy
  has_many :access_authorizes, dependent: :destroy
  after_save :delete_cache
  accepts_nested_attributes_for :column_authorizes, :access_authorizes, allow_destroy: true

  private

  def delete_cache
    Cache.delete_namespace("role-#{id}")
  end
end
