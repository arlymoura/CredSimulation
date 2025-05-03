require 'rails_helper'

RSpec.describe Simulation, type: :model do
  describe 'associations' do
    it { is_expected.to belong_to(:simulation_batch).optional }
  end

  describe 'enums' do
    it 'has valid statuses' do
      simulation = create(:simulation, status: :pending)
      expect(simulation).to be_pending
    end
  end
end
