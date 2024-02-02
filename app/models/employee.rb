class Employee < ApplicationRecord

  enum :status, {
    inactive: 0 ,
    active: 1
  }

  belongs_to :role
end
