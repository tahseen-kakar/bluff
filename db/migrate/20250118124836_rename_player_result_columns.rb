class RenamePlayerResultColumns < ActiveRecord::Migration[8.0]
  def change
    # Rename total_amount to cash_out_amount in player_results
    rename_column :player_results, :total_amount, :cash_out_amount

    # Change column type to decimal for consistency
    change_column :player_results, :cash_out_amount, :decimal, precision: 10, scale: 2

    # Add missing columns from previous migration if they don't exist
    unless column_exists?(:player_results, :buy_in_amount)
      add_column :player_results, :buy_in_amount, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    end

    unless column_exists?(:player_results, :loan_taken)
      add_column :player_results, :loan_taken, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    end

    # Update existing records to have valid buy_in_amount
    execute <<-SQL
      UPDATE player_results#{' '}
      SET buy_in_amount = CASE#{' '}
        WHEN cash_out_amount > 0 THEN cash_out_amount#{' '}
        ELSE 100.0#{' '}
      END
    SQL

    # Now add check constraints
    add_check_constraint :player_results, "buy_in_amount > 0", name: "check_buy_in_amount_positive"
    add_check_constraint :player_results, "loan_taken >= 0", name: "check_loan_taken_non_negative"
  end
end
