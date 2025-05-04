# spec/integration/api/v1/loans/simulation_batches_spec.rb

require 'swagger_helper'
require 'sidekiq/testing'

RSpec.describe 'API V1 Loans Simulation Batches', type: :request do # rubocop:disable RSpec/EmptyExampleGroup
  path '/api/v1/loans/simulation_batches' do
    post 'Create a Simulation Batch' do
      tags 'Simulation Batches'
      consumes 'application/json'
      produces 'application/json'

      parameter name: :simulation_batch, in: :body, schema: {
        type: :object,
        properties: {
          simulation_batch: {
            type: :object,
            properties: {
              email: { type: :string, format: :email, example: 'user@example.com' },
              sync: { type: :boolean, example: true },
              simulations_data: {
                type: :array,
                items: {
                  type: :object,
                  properties: {
                    loan_amount: { type: :number, example: 10_000 },
                    birth_date: { type: :string, format: :date, example: '2005-06-08' },
                    term_in_months: { type: :integer, example: 12 }
                  },
                  required: %w(loan_amount birth_date term_in_months)
                }
              }
            },
            example: {
              email: 'user@example.com',
              sync: false,
              simulations_data: [
                {
                  loan_amount: 10_000,
                  birth_date: '2005-06-08',
                  term_in_months: 12
                },
                {
                  loan_amount: 10_000,
                  birth_date: '2005-06-08',
                  term_in_months: 24
                },
                {
                  loan_amount: 10_000,
                  birth_date: '2005-06-08',
                  term_in_months: 48
                },
                {
                  loan_amount: 10_000,
                  birth_date: '2005-06-08',
                  term_in_months: 60
                }
              ]
            },
            required: ['simulations_data']
          }
        },
        required: ['simulation_batch']
      }

      response '200', 'Simulation batch created successfully (sync)' do
        let(:simulation_batch) do
          {
            simulation_batch: {
              email: 'user@example.com',
              sync: true,
              simulations_data: [
                {
                  loan_amount: 10_000,
                  birth_date: '2005-06-08',
                  term_in_months: 12
                },
                {
                  loan_amount: 10_000,
                  birth_date: '2005-06-08',
                  term_in_months: 24
                },
                {
                  loan_amount: 10_000,
                  birth_date: '2005-06-08',
                  term_in_months: 48
                },
                {
                  loan_amount: 10_000,
                  birth_date: '2005-06-08',
                  term_in_months: 60
                }
              ]
            }
          }
        end

        before do
          allow_any_instance_of(SimulationBatch).to receive(:completed?).and_return(true) # rubocop:disable RSpec/AnyInstance

          # rubocop:disable RSpec/AnyInstance
          # rubocop:disable RSpec/MessageChain
          allow_any_instance_of(SimulationBatch).to receive_message_chain(:simulations, :map).and_return(
            [
              [
                {
                  total_paid: 11_322.6,
                  total_interest: 1322.6,
                  payment_per_month: 188.71,
                  annual_interest_rate: 5.0,
                  simulation_id: '306f2ce7-3d03-4940-83c4-eb22e679e382',
                  simulation_batch_id: 'e2c81ff6-bcd0-4570-9cc3-043414b64e40'
                },
                {
                  total_paid: 11_053.92,
                  total_interest: 1053.92,
                  payment_per_month: 230.29,
                  annual_interest_rate: 5.0,
                  simulation_id: '716c5640-2d05-4d7c-bba3-787623e41ff7',
                  simulation_batch_id: 'e2c81ff6-bcd0-4570-9cc3-043414b64e40'
                },
                {
                  total_paid: 10_272.84,
                  total_interest: 272.84,
                  payment_per_month: 856.07,
                  annual_interest_rate: 5.0,
                  simulation_id: '1dbf8daa-70d3-42ba-9802-babf59e7e4ee',
                  simulation_batch_id: 'e2c81ff6-bcd0-4570-9cc3-043414b64e40'
                },
                {
                  total_paid: 10_529.04,
                  total_interest: 529.04,
                  payment_per_month: 438.71,
                  annual_interest_rate: 5.0,
                  simulation_id: 'aa8ce9b4-5cd7-4763-9cbf-f7933977b3a7',
                  simulation_batch_id: 'e2c81ff6-bcd0-4570-9cc3-043414b64e40'
                }
              ]
            ]
          )
          # rubocop:enable RSpec/AnyInstance
          # rubocop:enable RSpec/MessageChain
        end

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to be_a(Array)
        end
      end

      response '422', 'Invalid request (missing data)' do
        let(:simulation_batch) do
          {
            simulation_batch: {
              email: 'user@example.com',
              sync: true,
              simulations_data: []
            }
          }
        end
        run_test!
      end
    end
  end
end
