require 'rails_helper'

RSpec.describe SimulationBatch, type: :model do
  describe 'associations' do
    it { is_expected.to have_many(:simulations) }
  end

  describe 'validations' do
    it { is_expected.to validate_presence_of(:status) }
    it { is_expected.to validate_presence_of(:total_count) }
  end

  describe 'enums' do
    it 'has valid statuses' do
      batch = create(:simulation_batch, status: :pending)
      expect(batch).to be_pending
    end
  end
end
