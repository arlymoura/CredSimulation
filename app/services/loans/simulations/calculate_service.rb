module Loans
  module Simulations
    class CalculateService < ::ApplicationService
      def initialize(loan_amount_cents:, age:, term_in_months:)
        @loan_amount_cents = loan_amount_cents
        @age = age
        @term_in_months = term_in_months
      end

      def call
        monthly_rate = calculate_monthly_rate
        pmt_cents = calculate_pmt(monthly_rate)
        total_paid_cents = pmt_cents * @term_in_months
        total_interest_cents = total_paid_cents - @loan_amount_cents

        success(
          payment_per_month: pmt_cents,
          total_paid: total_paid_cents,
          total_interest: total_interest_cents,
          annual_interest_rate: calculate_annual_interest_rate(monthly_rate)
        )
      end

      private

      def calculate_monthly_rate
        annual_rate = determine_rate_by_age
        annual_rate / 12.0
      end

      def determine_rate_by_age
        case @age
        when 0..25 then 0.05
        when 26..40 then 0.03
        when 41..60 then 0.02
        else 0.04
        end
      end

      def calculate_pmt(monthly_rate)
        numerator = @loan_amount_cents * monthly_rate
        denominator = 1 - ((1 + monthly_rate)**-@term_in_months)
        (numerator / denominator).round(0).to_i
      end

      def calculate_annual_interest_rate(monthly_rate)
        (monthly_rate * 12 * 100).round(2)
      end
    end
  end
end
