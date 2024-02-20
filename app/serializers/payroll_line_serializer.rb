class PayrollLineSerializer
  include JSONAPI::Serializer
  attributes :row, :group, :payroll_type, :formula,
              :description, :variable1, :variable2,
              :variable3, :variable4, :variable5
end
