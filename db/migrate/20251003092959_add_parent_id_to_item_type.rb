class AddParentIdToItemType < ActiveRecord::Migration[7.1]
  def change
    add_column :tbl_itemjenis, :parent_id, :string
  end
end
