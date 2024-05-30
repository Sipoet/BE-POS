class CreateEmployeeDayOffs < ActiveRecord::Migration[7.1]
  def change
    create_table :employee_day_offs do |t|
      t.integer :day_of_week, null: false
      t.integer :active_week, default: 0, null: false
      t.integer :employee_id, null: false
      t.timestamps
    end
    add_foreign_key :employee_day_offs, :employees, column: :employee_id
  end
end
