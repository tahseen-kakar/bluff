class Table < ApplicationRecord
  belongs_to :user
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
