class CreateColumnAuthorizes < ActiveRecord::Migration[7.1]
  def change
    create_table :column_authorizes do |t|
      t.string :table, null: false
      t.string :column, null: false
      t.integer :role_id, null: false, index: true
      t.timestamps
    end
    add_foreign_key :column_authorizes, :roles, column: :role_id
  end
end
