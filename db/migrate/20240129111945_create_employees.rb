class CreateEmployees < ActiveRecord::Migration[7.1]
  def change
    create_table :employees do |t|
      t.string :code, null: false, index: { unique: true }
      t.string :name, null: false
      t.integer :role_id, null: false
      t.decimal :debt, null: false, default: 0
      t.date :start_working_date, null: false
      t.date :end_working_date
      t.integer :payroll_id
      t.integer :image_id
      t.integer :status, null: false, default: 0
      t.integer :shift, null: false, default: 1
      t.text :description
      t.string :id_number
      t.string :contact_number
      t.string :address
      t.string :bank
      t.string :bank_register_name
      t.string :bank_account
      t.timestamps
    end
    add_foreign_key :employees, :roles, column: :role_id
    add_foreign_key :employees, :payrolls, column: :payroll_id
  end
end
