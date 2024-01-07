class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include Devise::JWT::RevocationStrategies::JTIMatcher

  enum :role, {
    admin: 0,
    sales: 1,
    cashier: 2,
    marketing: 3,
    stock: 4,
    superadmin: 5,
    warehouse: 6,
    sales_manager: 7
  }

  devise :database_authenticatable,  :trackable, :lockable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  validates :email, uniqueness: true, allow_nil: true
  validates :username, presence: true
  validates :password, presence: true
end
