class CreateTables < ActiveRecord::Migration[8.0]
  def change
    create_table :tables do |t|
      t.string :name, null: false
      t.text :description
      t.references :user, null: false, foreign_key: true
      t.integer :games_count, default: 0  # Counter cache for games

      t.timestamps
    end

    add_index :tables, [ :user_id, :name ], unique: true
  end
end
