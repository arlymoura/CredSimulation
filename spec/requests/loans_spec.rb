# spec/requests/api/v1/loans_spec.rb
require 'rails_helper'

RSpec.describe 'Loans API', type: :request do
  describe 'POST /api/v1/loans/simulations' do
    subject(:run_request) { post url, params: params.to_json, headers: headers }

    let(:url) { '/api/v1/loans/simulations' }
    let(:headers) { { 'CONTENT_TYPE' => 'application/json', 'ACCEPT' => 'application/json' } }
    let(:parsed_body) { response.parsed_body }

    context 'with valid parameters' do
      let(:params) do
        {
          loan_amount: 10_000,
          birth_date: '2005-06-08',
          term_in_months: 24
        }
      end

      it 'returns success' do
        run_request

        expect(response).to have_http_status(:ok)

        expect(parsed_body).to include(
          'payment_per_month' => 438.71,
          'total_interest' => 529.04,
          'total_paid' => 10_529.04
        )
      end
    end

    context 'with missing birth_date' do
      let(:params) do
        {
          loan_amount: 10_000,
          birth_date: nil,
          term_in_months: 24
        }
      end

      it 'returns error' do
        run_request

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body['error']).to eq('Missing parameters: [:birth_date]')
      end
    end

    context 'with invalid loan amount' do
      let(:params) do
        {
          loan_amount: 0,
          birth_date: '2005-06-08',
          term_in_months: 24
        }
      end

      it 'returns error' do
        run_request

        expect(response).to have_http_status(:unprocessable_entity)
        expect(parsed_body['error']).to eq('Invalid loan amount')
      end
    end
  end
end
