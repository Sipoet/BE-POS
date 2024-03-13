class WorkScheduleSerializer
  include JSONAPI::Serializer
  attributes :shift, :day_of_week, :begin_work,
             :end_work, :active_week
end
