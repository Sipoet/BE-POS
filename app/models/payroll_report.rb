class PayrollReport < ApplicationModel

  attr_accessor :salary_details,
                :employee_name,
                :employee_id,
                :start_working_date
  attr_reader :map_details

  def initialize(row)
    @salary_details = *row[:salary_details] || []
    @map_details = @salary_details.index_by{|row|row.payroll_type_id.to_s}
    @employee_id = row[:employee_id].to_i
    @employee_name = row[:employee_name].to_s
    @start_working_date = row[:start_working_date]
  end

  def salary_total
    @salary_details.sum(&:full_amount)
  end

  def [](key)
    key = key.to_s
    if ['employee_id','employee_name','start_working_date'].include?(key)
      return instance_variable_get("@#{key}")
    end
    return salary_total if key == 'salary_total'
    @map_details[key].try(:main_amount)
  end
end
