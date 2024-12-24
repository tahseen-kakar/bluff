class GameFormat < ApplicationRecord
  belongs_to :table

  # Constants
  VALID_COLORS = {
    "white" => "#FFFFFF",
    "red" => "#EF4444",
    "blue" => "#3B82F6",
    "green" => "#10B981",
    "black" => "#1F2937",
    "purple" => "#8B5CF6",
    "yellow" => "#F59E0B",
    "pink" => "#EC4899"
  }.freeze

  validates :name, presence: true, uniqueness: { scope: :table_id }
  validates :buy_in, presence: true, numericality: { greater_than: 0 }
  validates :denominations, presence: true
  validate :validate_denominations_structure

  private

  def validate_denominations_structure
    return if denominations.blank?

    unless denominations.is_a?(Array) && denominations.all? { |d| valid_denomination?(d) }
      errors.add(:denominations, "must be an array of valid denomination objects")
    end
  end

  def valid_denomination?(denomination)
    denomination.is_a?(Hash) &&
    denomination["value"].present? &&
    denomination["color"].present? &&
    denomination["value"].to_f > 0 &&
    VALID_COLORS.key?(denomination["color"])
  end
end
