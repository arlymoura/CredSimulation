require 'csv'
# frozen_string_literal: true
module Loans
  module Simulations
    class BatchMailer < ApplicationMailer
      COLLUMN_NAMES = [
        'ID',
        'Loan Amount',
        'Interest Rate',
        'Term in months',
        'Status',
        'Payment per month',
        'Total Paid',
        'Total Interest',
        'Annual Interest Rate',
        'Created At'
      ].freeze

      def send_results
        @batch = params[:batch]

        @simulations = @batch.simulations
        attachments["simulation_batch_#{@batch.id}.csv"] = generate_csv(@simulations)
        mail(
          to: @batch.email,
          subject: 'Your simulation batch is complete' # rubocop:disable Rails/I18nLocaleTexts
        )
      end

      private

      # rubocop:disable Metrics/AbcSize
      # rubocop:disable Metrics/MethodLength
      def generate_csv(simulations)
        CSV.generate(headers: true) do |csv|
          csv << COLLUMN_NAMES

          simulations.each do |sim|
            csv << [
              sim.id,
              sim.loan_amount,
              sim.birth_date,
              sim.term_in_months,
              sim.status,
              sim.result['payment_per_month'],
              sim.result['total_paid'],
              sim.result['total_interest'],
              sim.result['annual_interest_rate'],
              sim.created_at
            ]
          end
        end
      end
      # rubocop:enable Metrics/MethodLength
      # rubocop:enable Metrics/AbcSize
    end
  end
end
