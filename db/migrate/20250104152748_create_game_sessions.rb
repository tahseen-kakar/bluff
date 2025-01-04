class CreateGameSessions < ActiveRecord::Migration[8.0]
  def change
    create_table :game_sessions do |t|
      t.references :table, null: false, foreign_key: true
      t.references :game_format, null: false, foreign_key: true
      t.integer :total_chips
      t.string :remarks

      t.timestamps
    end
  end
end
