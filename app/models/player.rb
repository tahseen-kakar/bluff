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

class Player < ApplicationRecord
  include PlayerStatistics

  # Constants
  DEFAULT_EMOJI = "🫥" # Default avatar emoji
  VALID_EMOJIS = %w[🫥 🎲 😀 😎 🤠 🥳 🤩 😇 🤪 🥸 🦹 🦸 🧙 🧛 🧜 🧝 🧞 🧟 🥷 👻 🤡 🎃 🎭] # Fun player avatars

  # Associations
  belongs_to :table
  has_many :player_results, dependent: :destroy
  has_many :game_sessions, through: :player_results
  has_many :transactions, dependent: :destroy

  # Callbacks
  before_validation :set_default_emoji

  # Validations
  validates :name, presence: true,
                  uniqueness: { scope: :table_id },
                  length: { maximum: 50 }
  validates :notes, length: { maximum: 500 }
  validates :emoji, presence: true,
                   inclusion: { in: VALID_EMOJIS }
  validates :wallet_balance, presence: true,
                          numericality: { greater_than_or_equal_to: 0 }
  validates :total_loan, presence: true,
                        numericality: { greater_than_or_equal_to: 0 }

  # Normalize attributes
  normalizes :name, with: ->(name) { name.strip }
  normalizes :notes, with: ->(notes) { notes&.strip }
  normalizes :emoji, with: ->(emoji) { emoji.presence }

  # Scopes
  scope :with_loans, -> { where("total_loan > 0") }
  scope :ordered_by_profit, -> { order("(wallet_balance - total_loan) DESC") }
  scope :active, -> { where("player_results_count > 0") }

  # Calculate loan needed for a game
  def loan_needed_for_game(buy_in_amount)
    return 0 if wallet_balance >= buy_in_amount
    buy_in_amount - wallet_balance
  end

  # Calculate current profit/loss
  def current_profit
    wallet_balance - total_loan
  end

  # Record game participation
  def participate_in_game(game_session, buy_in_amount)
    loan_amount = loan_needed_for_game(buy_in_amount)

    player_results.create!(
      game_session: game_session,
      buy_in_amount: buy_in_amount,
      loan_taken: loan_amount
    )

    if loan_amount > 0
      update!(
        total_loan: total_loan + loan_amount,
        wallet_balance: 0 # Since all cash is used before loan
      )
    else
      update!(wallet_balance: wallet_balance - buy_in_amount)
    end
  end

  private

  def set_default_emoji
    self.emoji ||= DEFAULT_EMOJI
  end
end
