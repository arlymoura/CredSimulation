module Loans
  class SimulationsController < ApplicationController
    def create
      simulation = ::Loans::SimulationService.call(** simulation_params.to_h.symbolize_keys)

      if simulation.success?
        render json: simulation.data, status: :ok
      else
        render json: { error: simulation.data }, status: :unprocessable_entity
      end
    end

    private

    def simulation_params
      params.require(:simulation).permit(:loan_amount, :birth_date, :term_in_months)
    end
  end
end
