FactoryBot.define do
  factory :employee_attendance, class: 'EmployeeAttendance' do
    start_time{DateTime.now}
    end_time {DateTime.now + 8.hours}
    date{Date.today}
    association :employee, factory: :active_employee
  end
end
