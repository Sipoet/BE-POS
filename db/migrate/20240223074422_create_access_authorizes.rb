class CreateAccessAuthorizes < ActiveRecord::Migration[7.1]
  def change
    create_table :access_authorizes do |t|
      t.string :controller, null: false
      t.string :action, null: false
      t.integer :role_id, null: false, index: true
      t.timestamps
    end
    add_foreign_key :access_authorizes, :roles, column: :role_id
  end
end
