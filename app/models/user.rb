class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include Devise::JWT::RevocationStrategies::JTIMatcher

  enum :role, [:admin, :sales, :cashier, :marketing, :stock, :superadmin,:warehouse]

  devise :database_authenticatable,  :trackable, :lockable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  validates :email, uniqueness: true, allow_nil: true
  validates :username, presence: true
  validates :password, presence: true
end
