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
  validates :wallet_balance, presence: true, numericality: true

  # Normalize attributes
  normalizes :name, with: ->(name) { name.strip }
  normalizes :notes, with: ->(notes) { notes&.strip }
  normalizes :emoji, with: ->(emoji) { emoji.presence }

  # Scopes
  scope :with_positive_balance, -> { where("wallet_balance > 0") }
  scope :with_negative_balance, -> { where("wallet_balance < 0") }
  scope :ordered_by_balance, -> { order(wallet_balance: :desc) }
  scope :active, -> { where("player_results_count > 0") }

  def record_transaction(amount:, type:, game_session: nil, notes: nil)
    transactions.create!(
      amount: amount,
      transaction_type: type,
      game_session: game_session,
      notes: notes
    )
  end

  private

  def set_default_emoji
    self.emoji ||= DEFAULT_EMOJI
  end
end
