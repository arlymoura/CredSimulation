require 'rails_helper'

RSpec.describe Loans::Simulations::CreateService, type: :service do
  let(:service_response) { described_class.call(**service_params) }

  describe '#call' do
    let(:birth_date) { 30.years.ago.to_date }
    let(:service_params) do
      {
        params: {
          loan_amount: 10_000.0,
          birth_date: '2005-06-08',
          term_in_months: 48
        },
        result: {
          payment_per_month: 230.29,
          total_paid: 11_053.92,
          total_interest: 1053.92,
          annual_interest_rate: 5.0
        }
      }
    end

    context 'with valid parameters' do
      it 'creates a simulation record successfully' do
        expect { service_response }.to change(Simulation, :count).by(1)
      end

      it 'saves correct attributes' do
        expect(service_response.data[:simulation]).to be_a(Simulation)
      end
    end

    context 'with invalid parameters' do
      let(:service_params) { {} }

      it 'raises an ArgumentError' do
        expect { service_response }.to raise_error(ArgumentError)
      end
    end
  end
end
