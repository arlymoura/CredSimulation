FactoryBot.define do
  factory :simulation do
    simulation_batch { nil }
    loan_amount { 10_000.00 }
    term_in_months { 12 }
    birth_date { 30.years.ago.to_date }
    result { nil }
    status { :pending }
  end
end
