class CreateTags < ActiveRecord::Migration[7.1]
  def change
    create_table :tags do |t|
      t.integer :parent_id
      t.string :value
      t.string :group
      t.timestamps
    end
  end
end
