class CreateEmployeeLeaves < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_leaves do |t|
      t.integer :employee_id, null: false
      t.integer :leave_type, null: false
      t.date :date, null: false
      t.date :change_date
      t.integer :change_shift
      t.text :description
      t.timestamps
    end
    add_foreign_key :employee_leaves, :employees, column: :employee_id
    add_index :employee_leaves, %i[employee_id date], unique: true
  end
end
