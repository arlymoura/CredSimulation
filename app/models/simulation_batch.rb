class SimulationBatch < ApplicationRecord
  has_many :simulations, dependent: :destroy

  enum :status, { pending: 0, processing: 1, completed: 2, failed: 3 }

  validates :status, :total_count, presence: true
end
