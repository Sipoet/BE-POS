class UpdateUser < ActiveRecord::Migration[7.1]
  def up
    remove_column :users, :role
    add_column :users, :role_id,:integer
    add_foreign_key :users, :roles, column: :role_id
  end


  def down
    add_column :users, :role, :integer
    remove_column :users, :role_id
    remove_foreign_key :users, :roles, column: :role_id
  end
end
