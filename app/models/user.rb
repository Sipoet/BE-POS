class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include Devise::JWT::RevocationStrategies::JTIMatcher
  TABLE_HEADER = [
    datatable_column(self,:username, :string),
    datatable_column(self,:email, :string),
    datatable_column(self,:role_name, :string)
  ]
  belongs_to :role

  devise :database_authenticatable,  :trackable, :lockable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  validates :email, uniqueness: true, allow_nil: true
  validates :username, presence: true

  def role_name
    role&.name
  end
end
