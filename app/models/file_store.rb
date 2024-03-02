class FileStore < ApplicationRecord

  validates :filename, presence: true
  validates :code, presence: true, uniqueness: true

  scope :expired_today, ->{where(['expired_at <= ?',Date.today.beginning_of_day])}
end
