class PayslipTotalDay < ActiveRecord::Migration[7.1]
  def change
    add_column :payslips, :total_day, :integer, null: false, default: 0
  end
end
