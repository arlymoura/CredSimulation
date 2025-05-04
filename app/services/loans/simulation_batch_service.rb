module Loans
  class SimulationBatchService < ::ApplicationService
    def initialize(simulations_data:, email: nil, sync: false)
      @simulations_data = simulations_data
      @user_email = email
      @sync = sync
    end

    def call
      return failure('Simulations data is empty') if @simulations_data.blank?

      @simulations_data.each do |sim_data|
        Loans::Simulations::ProcessBatchJob.perform_later(
          sim_data.merge(simulation_batch_id: batch_model.id)
        )
      end

      @sync ? wait_for_completion : success(batch_model)
    end

    def batch_model
      @batch_model ||= SimulationBatch.create!(
        status: :pending,
        total_count: @simulations_data.size,
        email: @user_email
      )
    end

    def wait_for_completion
      sleep(1) until batch_model.reload.completed?
      success(
        batch_model.simulations.map do |simulation|
          simulation.result.merge!(
            simulation_id: simulation.id,
            simulation_batch_id: simulation.simulation_batch_id,
            loan_amount: simulation.loan_amount,
            term_in_months: simulation.term_in_months,
            birth_date: simulation.birth_date
          )
        end
      )
    end
  end
end
