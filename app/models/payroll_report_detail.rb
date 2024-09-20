class PayrollReportDetail < ApplicationModel

  attr_accessor :main_amount,
                :full_amount,
                :payroll_type_name,
                :payroll_type_id,
                :is_earning

  def initialize(row)
    @main_amount = row[:main_amount]
    @full_amount = row[:full_amount]
    @payroll_type_id = row[:payroll_type_id].to_i
    @payroll_type_name = row[:payroll_type_name].to_s
    @is_earning = row[:is_earning] || false
  end

end
