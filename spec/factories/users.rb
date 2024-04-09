FactoryBot.define do
  factory :user do
    user_name  { Faker::Name.name }
    sequence(:email) { |n| "user-#{n}@gmail.com" }
    password {Faker::Internet.password(min_length: 6)}
  end
end
