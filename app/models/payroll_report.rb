class PayrollReport < ApplicationModel

  attr_accessor :salary_details,
                :employee_name,
                :employee_id
  attr_reader :map_details

  def initialize(row)
    @salary_details = *row[:salary_details] || []
    @map_details = @salary_details.index_by{|row|row.payroll_type_id.to_s}
    @employee_id = row[:employee_id].to_i
    @employee_name = row[:employee_name].to_s
  end

  def salary_total
    @salary_details.sum(&:full_amount)
  end

  def [](key)
    key = key.to_s
    if key == 'employee_id'
      return @employee_id
    end
    if key == 'employee_name'
      return @employee_name
    end
    if key == 'salary_total'
      return salary_total
    end
    @map_details[key].try(:main_amount)
  end
end
