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
    Cache.delete_namespace("role-#{id}-")
  end

  def self.superadmin_id
    cache = Cache.get('role-superadmin_id')
    return cache.to_i if cache.present?

    id = find_by(name: SUPERADMIN).id
    Cache.set('role-superadmin_id', id.to_s)
    id
  end

  def self.superadmin?(val)
    if val.is_a?(Role)
      val.name == SUPERADMIN
    else
      val == superadmin_id
    end
  end
end
