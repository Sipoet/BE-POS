FactoryBot.define do
  factory :role, class: 'Role' do
    # The alias allows us to write author instead of
    name { FFaker::Company.position }
    factory :role_superadmin do
      name { Role::SUPERADMIN }
    end
  end
end
