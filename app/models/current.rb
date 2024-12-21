class Current < ActiveSupport::CurrentAttributes
  attribute :session
  attribute :user
  attribute :table

  # If you want to keep the session delegation
  # delegate :user, to: :session, allow_nil: true
end
