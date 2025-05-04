require 'sidekiq'

module Loans
  module Simulations
    class ProcessBatchJob < ApplicationJob
      # include Sidekiq::Job
      queue_as :default

      def perform(simulation_data)
        Loans::SimulationService.call(**simulation_data)
      rescue StandardError => error
        Rails.logger.error("Failed to process simulation: #{error.message}")
      end
    end
  end
end
