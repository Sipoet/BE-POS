class AddMaritalStatus < ActiveRecord::Migration[7.1]
  def change

    add_column :employees, :marital_status, :integer, null: false, default: 0
    add_column :employees, :tax_number, :string

  end
end
