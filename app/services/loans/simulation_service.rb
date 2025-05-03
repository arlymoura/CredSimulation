module Loans
  class SimulationService < ::ApplicationService
    def initialize(loan_amount:, birth_date:, term_in_months:)
      @loan_amount = loan_amount
      @birth_date = birth_date
      @term_in_months = term_in_months
    end

    def call
      prepare_params_response = prepare_params
      return prepare_params_response if prepare_params_response.failure?

      pmt_cents = calculate_pmt
      total_paid_cents = pmt_cents * @term_in_months
      total_interest_cents = total_paid_cents - loan_amount_cents

      success(
        payment_per_month: cents_to_reais(pmt_cents),
        total_paid: cents_to_reais(total_paid_cents),
        total_interest: cents_to_reais(total_interest_cents),
        annual_interest_rate: ((monthly_rate * 12) * 100).round(2)
      )
    end

    attr_reader :loan_amount, :birth_date, :term_in_months

    private

    def prepare_params
      @prepare_params ||= ::Loans::PrepareSimulationParamsService.call(
        loan_amount: @loan_amount,
        birth_date: @birth_date,
        term_in_months: @term_in_months
      )
    end

    def loan_amount_cents
      prepare_params.data[:loan_amount_cents]
    end

    def birth_date_age
      prepare_params.data[:age]
    end

    def cents_to_reais(cents)
      (cents.to_f / 100).round(2)
    end

    def determine_rate_by_age
      case birth_date_age
      when 0..25 then 0.05
      when 26..40 then 0.03
      when 41..60 then 0.02
      else 0.04
      end
    end

    def monthly_rate
      annual_interest_rate = determine_rate_by_age
      annual_interest_rate / 12.0
    end

    def calculate_pmt
      numerator = loan_amount_cents * monthly_rate
      denominator = 1 - ((1 + monthly_rate)**-term_in_months)
      (numerator / denominator).round(0).to_i
    end
  end
end
