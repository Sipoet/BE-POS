class Payslip < ApplicationRecord
  has_paper_trail ignore: [:created_at, :updated_at]

  TABLE_HEADER = [
    datatable_column(self,:employee_id, :link,path:'employees',attribute_key: 'employee.name', sort_key:'employees.name'),
    datatable_column(self,:payroll_id, :link,path:'payrolls',attribute_key: 'payroll.name', sort_key:'payrolls.name'),
    datatable_column(self,:status, :enum),
    datatable_column(self,:start_date, :date),
    datatable_column(self,:end_date, :date),
    datatable_column(self,:work_days, :integer),
    datatable_column(self,:overtime_hour, :integer),
    datatable_column(self,:late, :integer),
    datatable_column(self,:sick_leave, :integer),
    datatable_column(self,:known_absence, :integer),
    datatable_column(self,:unknown_absence, :integer),
    datatable_column(self,:paid_time_off, :integer),
    datatable_column(self,:gross_salary, :decimal),
    datatable_column(self,:tax_amount, :decimal),
    datatable_column(self,:nett_salary, :decimal),
    datatable_column(self,:created_at, :datetime),
    datatable_column(self,:updated_at, :datetime),
  ];
  enum :status, {
    draft: 0,
    confirmed: 1,
    paid: 2,
    cancelled: 3
  }
  belongs_to :payroll
  belongs_to :employee
  has_many :payslip_lines, dependent: :destroy, inverse_of: :payslip
  accepts_nested_attributes_for :payslip_lines, allow_destroy: true
  [:work_days, :sick_leave, :known_absence, :unknown_absence].each do |key|
    validates key, presence: true, numericality:{greater_than_or_equal_to: 0}
  end
end
