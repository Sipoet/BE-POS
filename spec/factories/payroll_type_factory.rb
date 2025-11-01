FactoryBot.define do
  factory :payroll_type, class: 'PayrollType' do
    # The alias allows us to write author instead of
    name {'test'}
    initial {'TS'}
    order {rand(1..10)}
  end


end
