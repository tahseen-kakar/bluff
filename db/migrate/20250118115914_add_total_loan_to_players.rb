class AddTotalLoanToPlayers < ActiveRecord::Migration[8.0]
  def change
    add_column :players, :total_loan, :decimal, precision: 10, scale: 2, null: false, default: 0.0
    add_check_constraint :players, "total_loan >= 0", name: "check_total_loan_non_negative"
  end
end
