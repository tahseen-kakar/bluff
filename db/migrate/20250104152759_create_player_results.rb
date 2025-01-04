class CreatePlayerResults < ActiveRecord::Migration[8.0]
  def change
    create_table :player_results do |t|
      t.references :game_session, null: false, foreign_key: true
      t.references :player, null: false, foreign_key: true
      t.json :chip_counts
      t.integer :total_amount

      t.timestamps
    end
  end
end
