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

class GameSession < ApplicationRecord
  belongs_to :table
  belongs_to :game_format
  has_many :player_results, dependent: :destroy
  has_many :players, through: :player_results

  validates :total_chips, presence: true, if: :recording_chips?
  validate :validate_total_chips, if: :recording_chips?
  validates :player_results, presence: true, if: :recording_chips?

  attr_accessor :recording_chips

  def recording_chips?
    recording_chips.present?
  end

  def expected_total_chips
    game_format.buy_in * player_results.size
  end

  private

  def validate_total_chips
    return unless total_chips.present? && player_results.any?

    if (total_chips - expected_total_chips).abs > 0.01
      errors.add(:total_chips, "must equal #{expected_total_chips} (#{player_results.size} players × #{game_format.buy_in} buy-in)")
    end
  end
end
