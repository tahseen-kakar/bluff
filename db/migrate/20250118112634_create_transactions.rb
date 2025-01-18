class CreateTransactions < ActiveRecord::Migration[8.0]
  def change
    create_table :transactions do |t|
      t.references :player, null: false, foreign_key: true
      t.references :game_session, null: true, foreign_key: true
      t.decimal :amount, precision: 10, scale: 2, null: false
      t.decimal :balance_before, precision: 10, scale: 2, null: false
      t.decimal :balance_after, precision: 10, scale: 2, null: false
      t.string :transaction_type, null: false
      t.text :notes

      t.timestamps
    end

    add_index :transactions, [ :player_id, :created_at ]
    add_index :transactions, :transaction_type
  end
end
