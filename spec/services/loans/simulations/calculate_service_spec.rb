require 'rails_helper'

RSpec.describe Loans::Simulations::CalculateService, type: :service do
  let(:service_response) { described_class.call(**params) }
  let(:loan_amount_cents) { 10_000_00 }
  let(:age) { 24 }
  let(:term_in_months) { 24 }

  let(:params) do
    {
      loan_amount_cents: loan_amount_cents,
      age: age,
      term_in_months: term_in_months
    }
  end

  describe '#call' do
    context 'with valid data' do
      it 'returns correct calculation data' do
        expect(service_response).to be_success
        expect(service_response.data[:annual_interest_rate]).to eq(5.0)
        expect(service_response.data[:payment_per_month]).to eq(43_871)
        expect(service_response.data[:total_paid]).to eq(1_052_904)
        expect(service_response.data[:total_interest]).to eq(52_904)
      end
    end
  end
end
