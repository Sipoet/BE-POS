class AddRackColumn < ActiveRecord::Migration[7.1]
  def up
    add_column :tbl_itemstok, :rack, :string
  end

  def down
    remove_column :tbl_itemstok, :rack
  end
end
