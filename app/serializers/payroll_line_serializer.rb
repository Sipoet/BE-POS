class PayrollLineSerializer
  include JSONAPI::Serializer
  attributes :row, :group, :formula, :payroll_type_id,
             :description, :variable1, :variable2,
             :variable3, :variable4, :variable5

  belongs_to :payroll_type
end
