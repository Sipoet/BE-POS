FactoryBot.define do
  factory :employee, class: 'Employee' do
    code {SecureRandom.uuid}
    name {FFaker::NameID.name}
    association :role, factory: :role
    association :payroll, factory: :payroll
    start_working_date {Date.new(2023,2,23)}
    end_working_date {1.year.from_now}
    status {[:active,:inactive].sample}
    factory :active_employee do
      transient do
        status {:active}
      end
    end
    description {''}
  end
end
