class RoleWorkScheduleSerializer
  include JSONAPI::Serializer
  attributes :day_of_week,:shift,:begin_work,:end_work,
             :group_name,:begin_active_at, :end_active_at,
             :level
end
