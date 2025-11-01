FactoryBot.define do
  factory :payroll_line, class: 'PayrollLine' do
    # The alias allows us to write author instead of
    row { 1 }
    group { :earning }
    association :payroll_type, factory: :payroll_type
    formula { :basic }
    description { ' line' }
    variable1 { rand(1..100) * 1_000 }
    variable2 { rand(1..100) }
    variable3 { rand(1..100) }
  end
end
