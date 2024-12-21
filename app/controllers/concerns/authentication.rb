module Authentication
  extend ActiveSupport::Concern

  included do
    before_action :resume_session
    before_action :require_authentication
    helper_method :authenticated?
  end

  class_methods do
    def allow_unauthenticated_access(**options)
      skip_before_action :require_authentication, **options
    end
  end

  private
    def authenticated?
      Current.session.present?
    end

    def require_authentication
      return if authenticated?

      redirect_to sign_in_path
    end

    def resume_session
      return if Current.session.present?

      if session_id = cookies.signed[:session_token]
        Current.session = Session.find_by(id: session_id)
      end
    end

    def set_current_session(session)
      Current.session = session
    end
end
