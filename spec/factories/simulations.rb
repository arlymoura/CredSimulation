FactoryBot.define do
  factory :simulation do
    simulation_batch { nil }
    loan_amount { 10_000.00 }
    term_in_months { 12 }
    birth_date { 30.years.ago.to_date }
    result { nil }
    status { :pending }

    trait :with_result do
      result do
        {
          total_paid: 10272.84,
          total_interest: 272.84,
          payment_per_month: 856.07,
          annual_interest_rate: 5.0,
        }
      end
    end
  end


end
