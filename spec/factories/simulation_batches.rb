FactoryBot.define do
  factory :simulation_batch do
    status { :pending }
    total_count { 1 }
    email { Faker::Internet.email }
  end
end
