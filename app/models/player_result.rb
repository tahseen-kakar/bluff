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

class PlayerResult < ApplicationRecord
  belongs_to :game_session
  belongs_to :player

  validates :chip_counts, presence: true, if: -> { game_session.recording_chips? }
  validates :cash_out_amount, presence: true,
                             numericality: true,
                             if: -> { game_session.recording_chips? }
  validates :buy_in_amount, presence: true,
                           numericality: { greater_than: 0 }
  validates :loan_taken, presence: true,
                        numericality: { greater_than_or_equal_to: 0 }

  before_validation :calculate_cash_out_amount
  after_save :update_player_cash, if: -> { game_session.recording_chips? }

  # Calculate profit/loss for this game
  def profit_loss
    cash_out_amount - buy_in_amount
  end

  private

  def calculate_cash_out_amount
    return if chip_counts.blank?

    self.cash_out_amount = chip_counts.sum do |color, count|
      denomination = game_session.game_format.denominations.find { |d| d["color"] == color }
      next 0 unless denomination

      count.to_i * denomination["value"].to_f
    end
  end

  def update_player_cash
    # Update player's cash in hand based on game result
    if loan_taken > 0
      player.update!(
        total_loan: player.total_loan + loan_taken,
        wallet_balance: cash_out_amount # All cash was from loan
      )
    else
      player.update!(
        wallet_balance: player.wallet_balance - buy_in_amount + cash_out_amount
      )
    end
  end
end
