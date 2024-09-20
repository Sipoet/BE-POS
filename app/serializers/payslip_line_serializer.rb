class PayslipLineSerializer
  include JSONAPI::Serializer
  attributes :amount, :description, :payslip_type, :group,:formula

  belongs_to :payroll_type
end
