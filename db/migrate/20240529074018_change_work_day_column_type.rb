class ChangeWorkDayColumnType < ActiveRecord::Migration[7.1]
  def change
    change_column :payslips, :work_days, :decimal
  end
end
