class BookPayslipLineSerializer
  include JSONAPI::Serializer
  attributes :transaction_date, :amount, :group, :description, :status

  belongs_to :payroll_type
  belongs_to :employee
end
