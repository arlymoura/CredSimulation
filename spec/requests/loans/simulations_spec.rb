require 'swagger_helper'

RSpec.describe 'Loans API', type: :request do
  path '/api/v1/loans/simulations' do
    post 'Simulate a loan' do
      tags 'Loans'
      consumes 'application/json'
      produces 'application/json'
      parameter name: :simulation, in: :body, schema: {
        type: :object,
        properties: {
          loan_amount: { type: :integer },
          birth_date: { type: :string, format: :date },
          term_in_months: { type: :integer }
        },
        example: {
          loan_amount: 10_000,
          birth_date: '2005-06-08',
          term_in_months: 24
        },
        required: ['loan_amount', 'birth_date', 'term_in_months']
      }

      response(200, 'successful') do
        let(:simulation) do
          {
            loan_amount: 10_000,
            birth_date: '2005-06-08',
            term_in_months: 24
          }
        end

        run_test! do |response|
          expect(response.parsed_body).to include(
            'payment_per_month' => 438.71,
            'total_interest' => 529.04,
            'total_paid' => 10_529.04
          )
        end
      end

      response(422, 'unprocessable entity - missing birth_date') do
        let(:simulation) do
          {
            loan_amount: 10_000,
            birth_date: nil,
            term_in_months: 24
          }
        end

        run_test! do |response|
          expect(response.parsed_body['error']).to eq('Missing parameters: [:birth_date]')
        end
      end
    end
  end
end
