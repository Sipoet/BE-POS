class EmployeeLeaveSerializer
  include JSONAPI::Serializer
  attributes :date, :leave_type, :description, :change_date, :change_shift

  belongs_to :employee
end
