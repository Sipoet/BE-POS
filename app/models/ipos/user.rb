class Ipos::User < ApplicationRecord
  self.table_name = "tbl_user"
  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable,
  #         :validatable, :jwt_authenticatable, jwt_revocation_strategy: self
end
