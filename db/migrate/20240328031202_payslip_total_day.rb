class PayslipTotalDay < ActiveRecord::Migration[7.1]
  def up
    add_column :payslips, :total_day, :integer, null: false, default: 0
    change_column :payslips, :overtime_hour, :decimal, null: false, default: 0
  end

  def down
    remove_column :payslips, :total_day
    change_column :payslips, :overtime_hour, :integer, null: false, default: 0
  end
end
