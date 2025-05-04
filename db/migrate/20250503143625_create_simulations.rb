class CreateSimulations < ActiveRecord::Migration[8.0]
  def change
    create_table :simulations, id: :uuid do |t|
      t.references :simulation_batch, type: :uuid, foreign_key: true, null: true
      t.decimal :loan_amount, null: true
      t.integer :term_in_months, null: true
      t.string :birth_date, null: true
      t.jsonb :result
      t.integer :status, default: 0

      t.timestamps
    end
  end
end
