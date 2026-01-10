class Role < ApplicationRecord
  has_paper_trail ignore: %i[id created_at updated_at]

  SUPERADMIN = 'SUPERADMIN'.freeze

  has_many :column_authorizes, dependent: :destroy
  has_many :access_authorizes, dependent: :destroy
  has_many :role_work_schedules, dependent: :destroy
  validates :name, presence: true, uniqueness: true
  after_save :delete_cache
  after_destroy :delete_cache
  accepts_nested_attributes_for :column_authorizes, :access_authorizes, :role_work_schedules, allow_destroy: true

  private

  def delete_cache
    Cache.delete_namespace("role-#{id}")
    Cache.delete("column-authorizer-#{id}")
  end

  def self.superadmin_id
    (Cache.get('superadmin_id') || find_superadmin_id).to_i
  end

  def self.find_superadmin_id
    id = find_by(name: SUPERADMIN).id
    Cache.set('superadmin_id', id.to_s)
    id
  end
end
