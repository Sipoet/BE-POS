class AddReligionAndEmailToEmployee < ActiveRecord::Migration[7.1]
  def change
    add_column :employees, :email, :string
    add_column :employees, :religion, :integer, null: false, default: 0
    add_column :holidays, :religion, :integer
  end
end
