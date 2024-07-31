class UpdatePayslipLine < ActiveRecord::Migration[7.1]
  def up
    add_column :payslip_lines, :formula, :integer
    add_column :payslip_lines, :variable1, :decimal
    add_column :payslip_lines, :variable2, :decimal
    add_column :payslip_lines, :variable3, :decimal
    add_column :payslip_lines, :variable4, :decimal
    add_column :payslip_lines, :variable5, :decimal
    seed_payslip_line
  end

  def down
    remove_column :payslip_lines, :formula
    remove_column :payslip_lines, :variable1
    remove_column :payslip_lines, :variable2
    remove_column :payslip_lines, :variable3
    remove_column :payslip_lines, :variable4
    remove_column :payslip_lines, :variable5
  end
  private
  def seed_payslip_line
    ApplicationRecord.transaction do
      PayslipLine.includes(:payslip).find_each do |payslip_line|
        payroll = payslip_line.payslip.try(:payroll)
        next if payroll.nil?
        payroll_line = payroll.payroll_lines.find_by(description: payslip_line.description)
        next if payroll_line.nil?
        payslip_line.update!(
          formula: payroll_line.formula,
          variable1: payroll_line.variable1,
          variable2: payroll_line.variable2,
          variable3: payroll_line.variable3,
          variable4: payroll_line.variable4,
          variable5: payroll_line.variable5,
        )
      end
    end
  end
end
