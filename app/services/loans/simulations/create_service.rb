module Loans
  module Simulations
    class CreateService < ::ApplicationService
      def initialize(params:, result: {}, status: :pending, simulation_batch_id: nil)
        @params = params
        @result = result
        @simulation_batch_id = simulation_batch_id
        @status = status
      end

      def call
        simulation = Simulation.create!(
          loan_amount: @params[:loan_amount],
          term_in_months: @params[:term_in_months],
          birth_date: @params[:birth_date],
          status: @status,
          result: @result,
          simulation_batch_id: @simulation_batch_id
        )

        success(simulation: simulation)
      end
    end
  end
end
