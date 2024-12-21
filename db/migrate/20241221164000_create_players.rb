class CreatePlayers < ActiveRecord::Migration[8.0]
  def change
    create_table :players do |t|
      t.string :name, null: false
      t.string :email
      t.text :notes
      t.references :table, null: false, foreign_key: true

      t.timestamps
    end

    add_index :players, [ :table_id, :name ], unique: true
    add_index :players, [ :table_id, :email ], unique: true, where: "email IS NOT NULL"
  end
end
