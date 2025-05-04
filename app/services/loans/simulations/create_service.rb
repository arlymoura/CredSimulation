module Loans
  module Simulations
    class CreateService < ::ApplicationService
      def initialize(params:, result:, simulation_batch_id: nil)
        @params = params
        @result = result
        @simulation_batch_id = simulation_batch_id
      end

      def call
        simulation = Simulation.create!(
          loan_amount: @params[:loan_amount],
          term_in_months: @params[:term_in_months],
          birth_date: @params[:birth_date],
          status: :completed,
          result: {
            payment_per_month: @result[:payment_per_month],
            total_paid: @result[:total_paid],
            total_interest: @result[:total_interest],
            annual_interest_rate: @result[:annual_interest_rate]
          },
          simulation_batch_id: @simulation_batch_id
        )

        success(simulation: simulation)
      end
    end
  end
end
