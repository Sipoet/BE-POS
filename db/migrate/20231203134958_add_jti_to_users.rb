class AddJtiToUsers < ActiveRecord::Migration[7.0]
  def self.up
    add_column :users, :jti, :string, null: false
    add_index :users, :jti
  end

  def self.down
    remove_column :users, :jti
  end
end
