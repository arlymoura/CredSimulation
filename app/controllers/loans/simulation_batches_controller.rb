module Loans
  class SimulationBatchesController < ApplicationController
    def create
      simulation = ::Loans::SimulationBatchService.call(**simulation_params.to_h.deep_symbolize_keys)

      if simulation.success?
        render json: simulation.data, status: :ok
      else
        render json: { error: simulation.data }, status: :unprocessable_entity
      end
    end

    private

    def simulation_params
      params.require(:simulation_batch).permit(
        :email, :sync, simulations_data: %i(loan_amount birth_date term_in_months)
      )
    end
  end
end
