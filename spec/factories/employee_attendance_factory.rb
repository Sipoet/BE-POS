FactoryBot.define do
  factory :employee_attendance, class: 'EmployeeAttendance' do
    start_time {DateTime.parse("#{date.iso8601} #{employee.role.role_work_schedules.first.begin_work}") rescue '08:00'}
    end_time {DateTime.parse("#{date.iso8601} #{employee.role.role_work_schedules.first.end_work}")rescue '15:00'}
    date{Date.today}
    association :employee, factory: :active_employee

    trait :late do
      start_time {DateTime.parse("#{date.iso8601} #{employee.role.role_work_schedules.first.begin_work}")+ 1.hour}
      is_late{true}
    end

    factory :overtime do
      end_time {DateTime.parse("#{date.iso8601} #{employee.role.role_work_schedules.first.end_work}")+ 2.hours}
      allow_overtime{true}
    end
  end
end

def parse_time(date,time)
  DateTime.parse("#{date.iso8601} #{time}")
end
