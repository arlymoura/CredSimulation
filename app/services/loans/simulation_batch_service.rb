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
        batch_model.simulations.pluck(:id, :result, :simulation_batch_id).map do |sim_id, result, sim_batch_id|
          result.merge!(simulation_id: sim_id, simulation_batch_id: sim_batch_id)
        end
      )
    end
  end
end
