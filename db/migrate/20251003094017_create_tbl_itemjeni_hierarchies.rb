class CreateTblItemjeniHierarchies < ActiveRecord::Migration[7.1]
  def change
    create_table :tbl_itemjeni_hierarchies, id: false do |t|
      t.string :ancestor_id, null: false
      t.string :descendant_id, null: false
      t.integer :generations, null: false
    end

    add_index :tbl_itemjeni_hierarchies, [:ancestor_id, :descendant_id, :generations],
      unique: true,
      name: "item_type_anc_desc_idx"

    add_index :tbl_itemjeni_hierarchies, [:descendant_id],
      name: "item_type_desc_idx"
  end
end
