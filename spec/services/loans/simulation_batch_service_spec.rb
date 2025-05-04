# spec/services/loans/simulation_batch_service_spec.rb
require 'rails_helper'

RSpec.describe Loans::SimulationBatchService do
  let(:service_response) { described_class.call(**params) }
  let(:simulations_data) do
    [
      { loan_amount: 10_000, birth_date: '2005-06-08', term_in_months: 12 },
      { loan_amount: 10_000, birth_date: '2005-06-08', term_in_months: 24 },
      { loan_amount: 10_000, birth_date: '2005-06-08', term_in_months: 48 },
      { loan_amount: 10_000, birth_date: '2005-06-08', term_in_months: 60 }
    ]
  end

  let(:email) { 'test@example.com' }
  let(:sync) { false }
  let(:params) do
    {
      simulations_data: simulations_data,
      email: email,
      sync: sync
    }
  end

  describe '#call' do
    context 'when params are valid' do
      context 'when sync is false and email is present' do
        let(:email) { 'test@example.com' }

        it 'creates SimulationBatch and enqueues ProcessBatchJob' do
          expect { service_response }.to change(SimulationBatch, :count).by(1)
            .and have_enqueued_job(Loans::Simulations::ProcessBatchJob).exactly(4).times

          batch = SimulationBatch.last
          expect(batch.status).to eq('pending')
          expect(batch.total_count).to eq(4)
          expect(batch.email).to eq('test@example.com')
        end
      end

      context 'when sync is false and email is empty' do
        let(:email) { nil }

        it 'creates SimulationBatch and enqueues ProcessBatchJob' do
          expect { service_response }.to change(SimulationBatch, :count).by(1)
            .and have_enqueued_job(Loans::Simulations::ProcessBatchJob).exactly(4).times

          batch = SimulationBatch.last
          expect(batch.status).to eq('pending')
          expect(batch.total_count).to eq(4)
          expect(batch.email).to be_nil
        end
      end

      context 'when sync is true and email is present' do
        let(:sync) { true }
        let(:email) { 'test@example.com' }
        let(:batch) { create(:simulation_batch, status: :pending, total_count: 2) }

        before do
          allow_any_instance_of(described_class).to receive(:batch_model).and_return(batch) # rubocop:disable RSpec/AnyInstance
          allow(Loans::Simulations::ProcessBatchJob).to receive(:perform_later)
          allow(batch).to receive(:reload).and_return(batch, batch)

          create(:simulation, :with_result, simulation_batch_id: batch.id, status: :completed)
          create(:simulation, :with_result, simulation_batch_id: batch.id, status: :completed)

          batch.update!(status: :completed)
        end

        it 'waits for completion and returns simulations results' do
          expect(service_response).to be_success
          expect(service_response.data.size).to eq(2)
        end
      end

      context 'when sync is true and emai is empty' do
        let(:sync) { true }
        let(:email) { nil }
        let(:batch) { create(:simulation_batch, status: :pending, total_count: 2) }

        before do
          allow_any_instance_of(described_class).to receive(:batch_model).and_return(batch) # rubocop:disable RSpec/AnyInstance
          allow(Loans::Simulations::ProcessBatchJob).to receive(:perform_later)
          allow(batch).to receive(:reload).and_return(batch, batch)

          create(:simulation, :with_result, simulation_batch_id: batch.id, status: :completed)
          create(:simulation, :with_result, simulation_batch_id: batch.id, status: :completed)

          batch.update!(status: :completed)
        end

        it 'waits for completion and returns simulations results' do
          expect(service_response).to be_success
          expect(service_response.data.size).to eq(2)
        end
      end

      context 'when simulation_batch status is completed' do
        let(:sync) { true }
        let(:email) { nil }
        let(:batch) { create(:simulation_batch, status: :pending, total_count: 2) }

        before do
          allow_any_instance_of(described_class).to receive(:batch_model).and_return(batch) # rubocop:disable RSpec/AnyInstance
          allow(Loans::Simulations::ProcessBatchJob).to receive(:perform_later)

          allow(batch).to receive(:reload).and_wrap_original do |_m, *args| # rubocop:disable Lint/UnusedBlockArgument
            batch.status == 'pending' ? batch.tap { batch.update!(status: :completed) } : batch
          end

          create(:simulation, :with_result, simulation_batch: batch, status: :completed)
          create(:simulation, :with_result, simulation_batch: batch, status: :completed)
        end

        it 'waits for completion and returns simulations results' do
          expect(service_response).to be_success
          expect(service_response.data.size).to eq(2)
        end
      end
    end

    context 'when params are invalid' do
      context 'when simulations_data is empty' do
        let(:simulations_data) { [] }

        it 'returns failure' do
          expect(service_response).to be_failure
          expect(service_response.data).to eq('Simulations data is empty')
        end
      end
    end
  end
end
