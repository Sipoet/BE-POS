class Holiday < ApplicationRecord
  enum :religion, {
    other: 0,
    catholic: 6,
    christian: 1,
    buddhism: 2,
    hindu: 3,
    islam: 4,
    khonghucu: 5
  }

  validates :date, presence: true
  validates :description, presence: true
end
