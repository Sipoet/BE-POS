class InitialPayrollType < ActiveRecord::Migration[7.1]
  def change
    add_column :payroll_types, :initial, :string
    add_column :payroll_types, :is_show_on_payslip_desc, :boolean, null: false, default: false
    add_column :payroll_types, :order, :integer, null: false, default: 1
  end
end
