class EmployeeDayOffSerializer
  include JSONAPI::Serializer
  attributes :day_of_week, :active_week
end
