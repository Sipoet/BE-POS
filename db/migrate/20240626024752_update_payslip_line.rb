class UpdatePayslipLine < ActiveRecord::Migration[7.1]
  def change
    add_column :payslip_lines, :formula, :integer
    add_column :payslip_lines, :variable1, :decimal
    add_column :payslip_lines, :variable2, :decimal
    add_column :payslip_lines, :variable3, :decimal
    add_column :payslip_lines, :variable4, :decimal
    add_column :payslip_lines, :variable5, :decimal
  end
end
