class GameFormat < ApplicationRecord
  belongs_to :table

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
    denomination["value"].to_f > 0
  end
end
