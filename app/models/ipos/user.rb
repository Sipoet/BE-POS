class Ipos::User < ApplicationRecord
  self.table_name = 'tbl_user'
  self.primary_key = 'userid'

  # Include default devise modules. Others available are:
  # :confirmable, :lockable, :timeoutable, :trackable and :omniauthable
  # devise :database_authenticatable,
  #         :validatable, :jwt_authenticatable, jwt_revocation_strategy: self
  alias_attribute :id, :userid
  alias_attribute :name, :nama
end
