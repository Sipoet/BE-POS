FactoryBot.define do
  factory :payroll, class: 'Payroll' do
    # The alias allows us to write author instead of
    name {FFaker::NameID.name}
    description {''}
    paid_time_off {0}
    after(:build) do |record|
      payroll_line = FactoryBot.build(:payroll_line)
      record.payroll_lines.build(payroll_line.attributes)
    end
  end


end
