class BookEmployeeAttendanceSerializer
  include JSONAPI::Serializer
  attributes :start_date, :end_date, :employee_id, :allow_overtime, :is_late, :is_flexible, :created_at, :updated_at
  belongs_to :employee
end
