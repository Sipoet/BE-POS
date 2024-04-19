class CreateHolidays < ActiveRecord::Migration[7.1]
  def change
    create_table :holidays do |t|
      t.date :date, null: false
      t.text :description, null: false
      t.timestamps
    end
    add_index :holidays, :date, unique: true
  end
end
