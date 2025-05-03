FactoryBot.define do
  factory :simulation_batch do
    status { :pending }
    total_count { 1 }
  end
end
