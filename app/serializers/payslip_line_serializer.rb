class PayslipLineSerializer
  include JSONAPI::Serializer
  attributes :amount, :description, :payslip_type, :group,:formula
end
