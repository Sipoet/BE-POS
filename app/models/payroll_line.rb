class PayrollLine < ApplicationRecord
  has_paper_trail

  enum :group,{
    earning: 0,
    deduction: 1
  }

  enum :payroll_type, {
    base_salary: 0, #gaji pokok
    incentive: 1, #tunjangan
    insurance: 2,
    debt: 3, #panjar
    commission: 4,
    tax: 5
  }

  enum :formula,{
    basic: 0,
    fulltime: 1,
    overtime_hour: 2,
    period_proportional: 3,
  }
end
