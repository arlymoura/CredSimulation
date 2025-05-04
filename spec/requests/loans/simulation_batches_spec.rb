# spec/integration/api/v1/loans/simulation_batches_spec.rb

require 'swagger_helper'

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

        run_test! do |response|
          data = JSON.parse(response.body)
          expect(data).to include('success' => true)
          expect(data['data']).to be_an(Array)
        end
      end

      response '422', 'Invalid request (missing data)' do
        let(:simulation_batch) { { simulation_batch: { email: 'user@example.com' } } }
        run_test!
      end
    end
  end
end
