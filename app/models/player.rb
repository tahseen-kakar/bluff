class Player < ApplicationRecord
  belongs_to :table

  # Constants
  DEFAULT_EMOJI = "🫥🎲🎲🎲🎲🎲🎲🎲🎲🎲🎲🎲🎲🎲🎲🫥😀🎲🎲🎲🎲🎲🎲🎲🎲🎲🎲🎲🎲🎲🎲🎲🫥" # Default avatar emoji
  VALID_EMOJIS = %w[🫥🎲 😀 😎 🤠 🥳 🤩 😇 🤪 🥸 🦹 🦸 🧙 🧛 🧜 🧝 🧞 🧟 🥷 👻 🤡 🎃 🎭
                    👨‍⚕️ 👩‍⚕️ 👨‍🌾 👩‍🌾 👨‍🍳 👩‍🍳 👨‍🎓 👩‍🎓 👨‍🏫 👩‍🏫 👨‍🏭 👩‍🏭 👨‍💻 👩‍💻
                    👨‍💼 👩‍💼 👨‍🔧 👩‍🔧 👨‍🎨 👩‍🎨 👨‍✈️ 👩‍✈️ 👨‍🚀 👩‍🚀 👨‍⚖️ 👩‍⚖️] # Fun player avatars

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

  # Normalize attributes
  normalizes :name, with: ->(name) { name.strip }
  normalizes :notes, with: ->(notes) { notes&.strip }
  normalizes :emoji, with: ->(emoji) { emoji.presence }

  private

  def set_default_emoji
    self.emoji ||= DEFAULT_EMOJI
  end
end
