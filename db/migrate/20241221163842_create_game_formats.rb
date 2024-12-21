class CreateGameFormats < ActiveRecord::Migration[8.0]
  def change
    create_table :game_formats do |t|
      t.string :name, null: false
      t.text :description
      t.decimal :buy_in, precision: 10, scale: 2, null: false
      t.json :denominations, null: false, default: []
      t.references :table, null: false, foreign_key: true

      t.timestamps
    end

    add_index :game_formats, [ :table_id, :name ], unique: true
  end
end
