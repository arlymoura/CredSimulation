module Loans
  module Simulations
    class PrepareParamsService < ::ApplicationService
      def initialize(loan_amount:, birth_date:, term_in_months:)
        @loan_amount = loan_amount
        @birth_date = birth_date
        @term_in_months = term_in_months
      end

      def call
        return params_present_error unless params_present?

        normalized_loan_amount_cents = normalize_loan_amount
        return failure('Invalid loan amount') if invalid_loan_amount?(normalized_loan_amount_cents)

        normalized_birth_date = normalize_birth_date
        return failure('Invalid birth date') if invalid_birth_date?(normalized_birth_date)

        age = calculate_age(normalized_birth_date)
        return failure('Invalid birth date') if age <= 0

        normalized_term = @term_in_months.to_i
        return failure('Invalid term') if invalid_term?(normalized_term)

        success_response(normalized_loan_amount_cents, normalized_birth_date, normalized_term, age)
      end

      private

      def params_present?
        @loan_amount.present? && @birth_date.present? && @term_in_months.present?
      end

      def params_present_error
        return failure('Missing parameters: [:loan_amount]') if @loan_amount.blank?
        return failure('Missing parameters: [:birth_date]') if @birth_date.blank?

        failure('Missing parameters: [:term_in_months]')
      end

      def normalize_loan_amount
        (BigDecimal(@loan_amount.to_s) * 100).round(0).to_i
      rescue ArgumentError
        nil
      end

      def invalid_loan_amount?(normalized_loan_amount_cents)
        normalized_loan_amount_cents.nil? || normalized_loan_amount_cents <= 0
      end

      def normalize_birth_date
        return @birth_date if @birth_date.is_a?(Date)

        Date.parse(@birth_date.to_s)
      rescue ArgumentError
        nil
      end

      def invalid_birth_date?(normalized_birth_date)
        normalized_birth_date.nil? || normalized_birth_date > Time.zone.today
      end

      def invalid_term?(normalized_term)
        normalized_term <= 0
      end

      def calculate_age(birth_date)
        now = Time.zone.today
        age = now.year - birth_date.year
        age -= 1 if (birth_date.month > now.month) || (birth_date.month == now.month && birth_date.day > now.day)
        age
      end

      def success_response(normalized_loan_amount_cents, normalized_birth_date, normalized_term, age)
        success(
          loan_amount: @loan_amount,
          loan_amount_cents: normalized_loan_amount_cents,
          birth_date: normalized_birth_date,
          term_in_months: normalized_term,
          age: age
        )
      end
    end
  end
end
