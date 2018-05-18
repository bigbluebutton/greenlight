FactoryBot.define do
  
  factory :user do
    password = Faker::Internet.password(8)

    provider { %w(greenlight google twitter).sample }
    uid { rand(10 ** 8) }
    name { Faker::Name.first_name }
    username { Faker::Internet.user_name }
    email { Faker::Internet.email }
    password { password }
    password_confirmation { password }
  end

  factory :room do
    uid { rand(10 ** 8) }
    user { create(:user) }
  end

  factory :meeting do
    uid { rand(10 ** 8) }
    name { Faker::Pokemon.name }
    room { create(:room) }
  end
end