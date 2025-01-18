class UpdatePlayerAndResultColumns < ActiveRecord::Migration[8.0]
  def change
    # Update players table
    rename_column :players, :wallet_balance, :cash_in_hand
    add_check_constraint :players, "cash_in_hand >= 0", name: "check_cash_in_hand_non_negative"

    # Update player_results table
    change_column :player_results, :total_amount, :decimal, precision: 10, scale: 2
    add_column :player_results, :buy_in_amount, :decimal, precision: 10, scale: 2, null: false
    add_column :player_results, :loan_taken, :decimal, precision: 10, scale: 2, null: false, default: 0.0

    # Add index for faster calculations
    add_index :player_results, [ :player_id, :created_at ]
  end
end
