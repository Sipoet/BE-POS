class AccessAuthorize < ApplicationRecord
  validates :controller, presence: true
  validates :action, presence: true
  belongs_to :role

  after_save :delete_cache
  after_destroy :delete_cache

  private

  def delete_cache
    Cache.delete_namespace("role-#{role_id}-")
  end
end
