class CreateSimulationBatches < ActiveRecord::Migration[8.0]
  def change
    create_table :simulation_batches, id: :uuid do |t|
      t.integer :status, default: 0
      t.integer :total_count
      t.string :email, null: true

      t.timestamps
    end
  end
end
