class PayslipLineSerializer
  include JSONAPI::Serializer
  attributes :amount, :description, :payroll_type_id, :group,
             :variable1, :variable2, :formula,
             :variable3, :variable4, :variable5
  belongs_to :payroll_type
end
