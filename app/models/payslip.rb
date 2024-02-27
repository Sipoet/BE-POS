class Payslip < ApplicationRecord
  has_paper_trail

  TABLE_HEADER = [
    datatable_column(self,:employee_id, :link,path:'employees',attribute_key: 'employee.name', sort_key:'employees.name'),
    datatable_column(self,:payroll_id, :link,path:'payrolls',attribute_key: 'payroll.name', sort_key:'payrolls.name'),
    datatable_column(self,:status, :enum),
    datatable_column(self,:start_date, :date),
    datatable_column(self,:end_date, :date),
    datatable_column(self,:gross_salary, :decimal),
    datatable_column(self,:tax_amount, :decimal),
    datatable_column(self,:nett_salary, :decimal),
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
end
