class CreateBookEmployeeAttendances < ActiveRecord::Migration[7.1]
  def change
    create_table :book_employee_attendances do |t|
      t.date :start_date, null: false
      t.date :end_date, null: false
      t.text :description
      t.integer :employee_id
      t.boolean :allow_overtime
      t.boolean :is_late
      t.boolean :is_flexible
      t.timestamps
    end
    add_foreign_key :book_employee_attendances, :employees, column: :employee_id
  end
end
