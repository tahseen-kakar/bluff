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

  validates :chip_counts, presence: true
  validates :total_amount, presence: true, numericality: { greater_than_or_equal_to: 0 }

  before_validation :calculate_total_amount

  def calculate_total_amount
    return if chip_counts.blank?

    self.total_amount = chip_counts.sum do |color, count|
      denomination = game_session.game_format.denominations.find { |d| d["color"] == color }
      next 0 unless denomination

      count.to_i * denomination["value"].to_i
    end
  end
end
