class Tag < ApplicationRecord

  validates :group, presence: true
  validates :value, presence: true

  belongs_to :object, polymorphic: true
end
