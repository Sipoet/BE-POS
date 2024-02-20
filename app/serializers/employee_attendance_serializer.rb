class EmployeeAttendanceSerializer
  include JSONAPI::Serializer
  [:start_time, :end_time, :date].each do |key|
    attributes key do |obj|
      obj.send(key).iso8601
    end
  end

  belongs_to :employee
end
