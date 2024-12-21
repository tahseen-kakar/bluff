class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user
  attribute :table

  # Delegate user to session
  delegate :user, to: :session, allow_nil: true

  def user
    session&.user
  end
end
