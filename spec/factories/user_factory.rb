FactoryBot.define do
  factory :user do
    # The alias allows us to write author instead of
    # association :author, factory: :user
    username { FFaker::Internet.user_name }
    email { FFaker::Internet.email }
    jti { SecureRandom.uuid }
    password { 'password' }
    password_confirmation { 'password' }
    association :role, factory: :role
    factory :superadmin do
      after(:build) do |record|
        record.role = Role.find_by(name: Role::SUPERADMIN) || create(:role_superadmin)
      end
    end
  end
end
