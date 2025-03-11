class User < ApplicationRecord
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  include Devise::JWT::RevocationStrategies::JTIMatcher

  has_paper_trail ignore: [:id,:created_at, :updated_at, :jti,:encrypted_password, :sign_in_count, :current_sign_in_at,:last_sign_in_at]

  belongs_to :role

  devise :database_authenticatable,  :trackable, :lockable,
         :recoverable, :rememberable, :validatable, :jwt_authenticatable, jwt_revocation_strategy: self

  validates :email, uniqueness: true, allow_nil: true
  validates :username, presence: true

  def role_name
    role&.name
  end
end
