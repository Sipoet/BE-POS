class CreateSettings < ActiveRecord::Migration[7.1]
  def change
    create_table :settings do |t|
      t.string :key_name, null: false, index: true
      t.integer :user_id, index: true
      t.text :value, null: false
      t.timestamps
    end

    add_foreign_key :settings, :users, column: :user_id
  end
end
