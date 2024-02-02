FactoryBot.define do
  factory :employee, class: 'Employee' do
    # The alias allows us to write author instead of
    code {SecureRandom.uuid}
    name {FFaker::Employee.name}
    role {0}
    base_salary {1000}
    overtime_paid {10}
    debt {100}
    start_working_date {Date.yesterday}
    end_working_date {Date.tomorrow}
    status {1}
    description {''}
    begin_schedule {'08:00'}
    end_schedule {'15:00'}
    positional_allowance {150}
    attendance_allowance {50}
    paid_time_off {2}
  end


end
