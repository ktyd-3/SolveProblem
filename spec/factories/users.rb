FactoryBot.define do
  factory :user do
    user_name  { Faker::Name.name }
    sequence(:email) { |n| "user-#{n}@gmail.com" }
  end
end
