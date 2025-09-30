class AddUserCodeOnEmployee < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :user_code, :string
  end
end
