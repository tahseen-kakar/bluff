class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
  end

  def create
    Rails.logger.info "Login attempt with: #{params[:email_address]}"

    if user = User.find_by(email_address: params[:email_address])
      if user.authenticate(params[:password])
        Rails.logger.info "User authenticated: #{user.id}"
        session = user.sessions.create!(
          ip_address: request.ip,
          user_agent: request.user_agent
        )

        set_current_session(session)
        cookies.signed.permanent[:session_token] = { value: session.id, httponly: true }
        redirect_to app_path
      else
        Rails.logger.info "Password authentication failed"
        redirect_to new_session_path, alert: "Invalid email or password"
      end
    else
      Rails.logger.info "User not found"
      redirect_to new_session_path, alert: "Invalid email or password"
    end
  end

  def destroy
    Current.session&.destroy
    redirect_to root_path
  end
end
