class Holiday < ApplicationRecord

  validates :date, presence: true
  validates :description, presence: true
end
