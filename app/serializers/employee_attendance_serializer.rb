class EmployeeAttendanceSerializer
  include JSONAPI::Serializer
  [:start_time, :end_time, :date,:created_at,:updated_at].each do |key|
    attributes key do |obj|
      obj.send(key).iso8601
    end
  end
  attributes :shift, :is_late

  belongs_to :employee
end
