class BookPayslipLineSerializer
  include JSONAPI::Serializer
  attributes :transaction_date, :amount, :group, :description,
             :created_at, :updated_at, :status

  belongs_to :payroll_type
  belongs_to :employee
end
