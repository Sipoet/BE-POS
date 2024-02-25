class AccessAuthorize < ApplicationRecord

  validates :controller, presence: true
  validates :action, presence: true
  belongs_to :role

end
