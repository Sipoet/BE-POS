class RemovePayslipTypes < ActiveRecord::Migration[7.1]
  def change
    remove_column :payslip_lines, :payslip_type
  end
end
