class EmployeeAttendanceSerializer
  include JSONAPI::Serializer
  %i[start_time end_time date created_at updated_at].each do |key|
    attributes key do |obj|
      obj.send(key).iso8601
    end
  end
  attributes :shift, :is_late, :allow_overtime

  belongs_to :employee
end
