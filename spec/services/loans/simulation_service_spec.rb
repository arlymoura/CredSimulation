require 'rails_helper'

RSpec.describe Loans::SimulationService, type: :service do
  let(:service_response) { described_class.call(**params) }
  let(:params) { {} }

  describe '#call' do
    let(:loan_amount) { 10_000.0 }
    let(:term_in_months) { 24 }

    let(:params) do
      {
        loan_amount: loan_amount,
        birth_date: birth_date,
        term_in_months: term_in_months
      }
    end

    context 'when is valid' do
      context 'when client is up to 25 years old' do
        let(:birth_date) { 20.years.ago.to_date }

        it 'returns success' do
          expect(service_response).to be_success
        end

        it 'calculates with 5% annual interest rate' do
          expect(service_response.data[:annual_interest_rate]).to eq(5.0)
        end

        it 'calculates the correct payment per month' do
          expect(service_response.data[:payment_per_month]).to eq(438.71)
        end

        it 'calculates the correct total paid' do
          expect(service_response.data[:total_paid]).to eq(10_529.04)
        end

        it 'calculates the correct total interest' do
          expect(service_response.data[:total_interest]).to eq(529.04)
        end
      end

      context 'when the client turns 25 today' do
        let(:birth_date) { 25.years.ago.to_date + 1.day }

        it 'returns success' do
          expect(service_response).to be_success
        end

        it 'calculates with 5% annual interest rate' do
          expect(service_response.data[:annual_interest_rate]).to eq(5.0)
        end
      end

      context 'when client is between 26 and 40 years old' do
        let(:birth_date) { 30.years.ago.to_date }

        it 'returns success' do
          expect(service_response).to be_success
        end

        it 'calculates with 3% annual interest rate' do
          expect(service_response.data[:annual_interest_rate]).to eq(3.0)
        end
      end

      context 'when client is between 41 and 60 years old' do
        let(:birth_date) { 50.years.ago.to_date }

        it 'returns success' do
          expect(service_response).to be_success
        end

        it 'calculates with 2% annual interest rate' do
          expect(service_response.data[:annual_interest_rate]).to eq(2.0)
        end
      end

      context 'when client is over 60 years old' do
        let(:birth_date) { 70.years.ago.to_date }

        it 'returns success' do
          expect(service_response).to be_success
        end

        it 'calculates with 4% annual interest rate' do
          expect(service_response.data[:annual_interest_rate]).to eq(4.0)
        end
      end

      context 'when birth_date is string' do
        let(:birth_date) { '1990-01-01' }

        it 'returns success' do
          expect(service_response).to be_success
        end

        it 'calculates with 3% annual interest rate' do
          expect(service_response.data[:annual_interest_rate]).to eq(3.0)
        end
      end
    end

    context 'when is invalid' do
      context 'when birth_date is today (0 years old)' do
        let(:birth_date) { Time.zone.today }

        it 'returns failure' do
          expect(service_response).to be_failure
        end

        it 'data is Invalid birth date' do
          expect(service_response.data).to eq('Invalid birth date')
        end
      end

      context 'when birth_date is nil' do
        let(:birth_date) { nil }

        it 'returns failure' do
          expect(service_response).to be_failure
        end

        it 'data is Invalid birth date' do
          expect(service_response.data).to eq('Missing parameters: [:birth_date]')
        end
      end

      context 'when birth_date is in the future' do
        let(:birth_date) { 1.year.from_now.to_date }

        it 'returns failure' do
          expect(service_response).to be_failure
        end

        it 'data is Invalid birth date' do
          expect(service_response.data).to eq('Invalid birth date')
        end
      end

      context 'when loan_amount is zero' do
        let(:birth_date) { 20.years.ago.to_date }
        let(:loan_amount) { 0.0 }

        it 'returns failure' do
          expect(service_response).to be_failure
        end

        it 'data is Invalid loan amount' do
          expect(service_response.data).to eq('Invalid loan amount')
        end
      end

      context 'when loan_amount is nil' do
        let(:birth_date) { 20.years.ago.to_date }
        let(:loan_amount) { nil }

        it 'returns failure' do
          expect(service_response).to be_failure
        end

        it 'data is Invalid loan amount' do
          expect(service_response.data).to eq('Missing parameters: [:loan_amount]')
        end
      end

      context 'when term_in_months is missing' do
        let(:birth_date) { 20.years.ago.to_date }
        let(:term_in_months) { nil }

        it 'returns failure' do
          expect(service_response).to be_failure
        end

        it 'data is Invalid parameters' do
          expect(service_response.data).to eq('Missing parameters: [:term_in_months]')
        end
      end

      context 'when term_in_months is zero' do
        let(:birth_date) { 20.years.ago.to_date }
        let(:term_in_months) { 0 }

        it 'returns failure' do
          expect(service_response).to be_failure
        end

        it 'data is Invalid term' do
          expect(service_response.data).to eq('Invalid term')
        end
      end
    end
  end
end
