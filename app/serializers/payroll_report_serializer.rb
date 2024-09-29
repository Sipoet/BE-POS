class PayrollReportSerializer
  include JSONAPI::Serializer

  set_id :employee_id

  attributes :employee_id, :employee_name, :salary_total

  attribute :payroll_type_amount do |obj,params|
    payroll_types = params[:payroll_types] || []
    payroll_types.each_with_object({}) do |payroll_type,value|
      value[payroll_type.id.to_s] = obj[payroll_type.id].to_d
    end
  end
end
