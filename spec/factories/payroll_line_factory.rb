FactoryBot.define do
  factory :payroll_line, class: 'PayrollLine' do
    # The alias allows us to write author instead of
    row {1}
    group {0}
    payroll_type {0}
    formula {0}
    description {' '}
    variable1{rand(1..100)*1_000}
    variable2{rand(1..100)}
    variable3{rand(1..100)}
  end


end
