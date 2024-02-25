class EmployeeLeaveSerializer
  include JSONAPI::Serializer
  attributes :date, :leave_type, :description

  belongs_to :employee
end
