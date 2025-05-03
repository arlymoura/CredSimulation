module Loans
  class SimulationService < ::ApplicationService
    def initialize(loan_amount:, birth_date:, term_in_months:, simulation_batch: nil)
      @loan_amount = loan_amount
      @birth_date = birth_date
      @term_in_months = term_in_months
      @simulation_batch = simulation_batch
    end

    def call
      prepare_params_response = prepare_params_service
      return prepare_params_response if prepare_params_response.failure?

      calculation_response = calculation_service
      return calculation_response if calculation_response.failure?

      create_response = create_simulation_service
      return create_response if create_response.failure?

      success_response
    end

    private

    def prepare_params_service
      @prepare_params_service ||= ::Loans::Simulations::PrepareParamsService.call(
        loan_amount: @loan_amount,
        birth_date: @birth_date,
        term_in_months: @term_in_months
      )
    end

    def calculation_service
      @calculation_service ||= ::Loans::Simulations::CalculateService.call(
        loan_amount_cents: prepare_params_service.data[:loan_amount_cents],
        age: prepare_params_service.data[:age],
        term_in_months: @term_in_months
      )
    end

    def create_simulation_service
      @create_simulation_service ||= ::Loans::Simulations::CreateService.call(
        params: {
          loan_amount: @loan_amount,
          birth_date: @birth_date,
          term_in_months: @term_in_months
        },
        result: {
          payment_per_month: calculation_service.data[:payment_per_month],
          total_paid: calculation_service.data[:total_paid],
          total_interest: calculation_service.data[:total_interest],
          annual_interest_rate: calculation_service.data[:annual_interest_rate]
        },
        simulation_batch: @simulation_batch
      )
    end

    def success_response
      success(
        payment_per_month: cents_to_reais(calculation_service.data[:payment_per_month]),
        total_paid: cents_to_reais(calculation_service.data[:total_paid]),
        total_interest: cents_to_reais(calculation_service.data[:total_interest]),
        annual_interest_rate: calculation_service.data[:annual_interest_rate]
      )
    end

    def cents_to_reais(cents)
      (cents.to_f / 100).round(2)
    end
  end
end
