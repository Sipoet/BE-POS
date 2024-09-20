class CreatePayrollTypes < ActiveRecord::Migration[7.1]
  def change
    create_table :payroll_types do |t|
      t.string :name, null: false
      t.timestamps
    end
    add_column :payroll_lines, :payroll_type_id, :integer
    remove_column :payroll_lines, :payroll_type
    add_foreign_key :payroll_lines, :payroll_types, column: :payroll_type_id
    add_column :payslip_lines, :payroll_type_id, :integer
    add_foreign_key :payslip_lines, :payroll_types, column: :payroll_type_id
    ApplicationRecord.transaction do
      seed_payroll_type
    end
  end

  private
    def seed_payroll_type
      PayrollLine.all.group_by(&:description).each do |name,payroll_lines|
        payroll_type = PayrollType.find_or_create_by!(name: name.strip.capitalize)
        PayrollLine.where(id: payroll_lines.pluck(:id))
                   .update_all(payroll_type_id: payroll_type.id)
        PayslipLine.where(description: name).update_all(payroll_type_id: payroll_type.id)
      end
    end

end
