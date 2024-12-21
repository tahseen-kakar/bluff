class Player < ApplicationRecord
  belongs_to :table

  # Validations
  validates :name, presence: true,
                  uniqueness: { scope: :table_id },
                  length: { maximum: 50 }
  validates :email, length: { maximum: 255 },
                   format: { with: URI::MailTo::EMAIL_REGEXP, allow_blank: true }
  validates :notes, length: { maximum: 500 }

  # Normalize attributes
  normalizes :name, with: ->(name) { name.strip }
  normalizes :email, with: ->(email) { email&.strip&.downcase }
  normalizes :notes, with: ->(notes) { notes&.strip }
end
