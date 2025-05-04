require 'rails_helper'

RSpec.describe Loans::Simulations::ProcessBatchJob, type: :job do
  let!(:simulation_batch) { create(:simulation_batch) }

  let(:simulation_data) do
    {
      loan_amount: 10_000,
      birth_date: '2005-06-08',
      term_in_months: 12,
      simulation_batch_id: simulation_batch.id
    }
  end

  describe '#perform' do
    it 'calls the SimulationService with the correct data' do
      expect(Loans::SimulationService).to receive(:call).with(**simulation_data)
      described_class.perform_now(simulation_data)
    end

    it 'logs an error if SimulationService raises an error' do
      allow(Loans::SimulationService).to receive(:call).and_raise(StandardError, 'something went wrong')
      expect(Rails.logger).to receive(:error).with(/Failed to process simulation: something went wrong/)

      described_class.perform_now(simulation_data)
    end
  end
end
