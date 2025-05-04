# spec/services/loans/prepare_simulation_params_service_spec.rb
require 'rails_helper'

RSpec.describe Loans::Simulations::PrepareParamsService, type: :service do
  let(:service_response) { described_class.call(**params) }
  let(:loan_amount) { 10_000.0 }
  let(:term_in_months) { 24 }
  let(:params) do
    {
      loan_amount: loan_amount,
      birth_date: birth_date,
      term_in_months: term_in_months
    }
  end

  describe '#call' do
    context 'when parameters are valid' do
      let(:birth_date) { 30.years.ago.to_date }

      it 'returns success' do
        expect(service_response).to be_success
      end

      it 'returns loan_amount in cents' do
        expect(service_response.data[:loan_amount_cents]).to eq(1_000_000)
      end

      it 'returns normalized birth_date as Date' do
        expect(service_response.data[:birth_date]).to eq(birth_date)
      end

      it 'returns correct age' do
        expect(service_response.data[:age]).to eq(30)
      end

      it 'returns correct term_in_months' do
        expect(service_response.data[:term_in_months]).to eq(term_in_months)
      end
    end

    context 'when loan_amount is missing' do
      let(:loan_amount) { nil }
      let(:birth_date) { 30.years.ago.to_date }

      it 'returns failure' do
        expect(service_response).to be_failure
      end

      it 'returns missing loan_amount message' do
        expect(service_response.data).to eq('Missing parameters: [:loan_amount]')
      end
    end

    context 'when birth_date is missing' do
      let(:loan_amount) { 10_000.0 }
      let(:birth_date) { nil }

      it 'returns failure' do
        expect(service_response).to be_failure
      end

      it 'returns missing birth_date message' do
        expect(service_response.data).to eq('Missing parameters: [:birth_date]')
      end
    end

    context 'when term_in_months is missing' do
      let(:loan_amount) { 10_000.0 }
      let(:birth_date) { 30.years.ago.to_date }
      let(:term_in_months) { nil }

      it 'returns failure' do
        expect(service_response).to be_failure
      end

      it 'returns missing term_in_months message' do
        expect(service_response.data).to eq('Missing parameters: [:term_in_months]')
      end
    end

    context 'when loan_amount is invalid (zero)' do
      let(:loan_amount) { 0 }
      let(:birth_date) { 30.years.ago.to_date }

      it 'returns failure' do
        expect(service_response).to be_failure
      end

      it 'returns invalid loan amount message' do
        expect(service_response.data).to eq('Invalid loan amount')
      end
    end

    context 'when birth_date is invalid (today)' do
      let(:loan_amount) { 10_000.0 }
      let(:birth_date) { Time.zone.today }

      it 'returns failure' do
        expect(service_response).to be_failure
      end

      it 'returns invalid birth date message' do
        expect(service_response.data).to eq('Invalid birth date')
      end
    end

    context 'when birth_date is in the future' do
      let(:loan_amount) { 10_000.0 }
      let(:birth_date) { 1.year.from_now.to_date }

      it 'returns failure' do
        expect(service_response).to be_failure
      end

      it 'returns invalid birth date message' do
        expect(service_response.data).to eq('Invalid birth date')
      end
    end

    context 'when term_in_months is invalid (zero)' do
      let(:loan_amount) { 10_000.0 }
      let(:birth_date) { 30.years.ago.to_date }
      let(:term_in_months) { 0 }

      it 'returns failure' do
        expect(service_response).to be_failure
      end

      it 'returns invalid term message' do
        expect(service_response.data).to eq('Invalid term')
      end
    end

    context 'when loan_amount is string' do
      let(:loan_amount) { '10000.0' }
      let(:birth_date) { 30.years.ago.to_date }

      it 'returns success' do
        expect(service_response).to be_success
      end

      it 'returns loan_amount_cents correctly' do
        expect(service_response.data[:loan_amount_cents]).to eq(1_000_000)
      end
    end

    context 'when birth_date is string' do
      let(:birth_date) { 30.years.ago.to_date.to_s }

      it 'returns success' do
        expect(service_response).to be_success
      end

      it 'returns normalized birth_date as Date' do
        expect(service_response.data[:birth_date]).to eq(30.years.ago.to_date)
      end
    end
  end
end
