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

class Table < ApplicationRecord
  belongs_to :user
  has_many :players, dependent: :destroy
  has_many :game_formats, dependent: :destroy

  # Validations
  validates :name, presence: true,
                  uniqueness: { scope: :user_id },
                  length: { maximum: 50 }
  validates :description, length: { maximum: 500 }

  # Normalize attributes
  normalizes :name, with: ->(name) { name.strip }
  normalizes :description, with: ->(desc) { desc&.strip }
end
