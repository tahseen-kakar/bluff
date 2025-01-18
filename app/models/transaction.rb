# This file is part of Bluff.
#
# Bluff is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
#
# Bluff is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Bluff.
# If not, see <https://www.gnu.org/licenses/>.

class Transaction < ApplicationRecord
  belongs_to :player
  belongs_to :game_session, optional: true

  # Enums for transaction types
  enum transaction_type: {
    buy_in: "buy_in",       # Player buys into a game
    cash_out: "cash_out",   # Player cashes out from a game
    loan: "loan",           # Player takes a loan
    repayment: "repayment"  # Player repays a loan
  }

  # Validations
  validates :amount, presence: true, numericality: { greater_than: 0 }
  validates :transaction_type, presence: true
  validates :balance_before, presence: true, numericality: true
  validates :balance_after, presence: true, numericality: true
  validate :validate_balance_change

  # Callbacks
  before_validation :set_balances
  after_create :update_player_wallet
  after_rollback :handle_failed_transaction

  private

  def set_balances
    return if balance_before.present? && balance_after.present?

    self.balance_before = player.wallet_balance
    self.balance_after = calculate_balance_after
  end

  def calculate_balance_after
    case transaction_type
    when "buy_in", "loan"
      balance_before - amount
    when "cash_out", "repayment"
      balance_before + amount
    else
      balance_before
    end
  end

  def validate_balance_change
    return unless balance_before && balance_after

    expected_after = calculate_balance_after
    if (balance_after - expected_after).abs > 0.01
      errors.add(:balance_after, "should be #{expected_after}")
    end
  end

  def update_player_wallet
    player.update!(wallet_balance: balance_after)
  end

  def handle_failed_transaction
    Rails.logger.error "Transaction failed for player #{player_id}: #{errors.full_messages.join(', ')}"
  end
end
