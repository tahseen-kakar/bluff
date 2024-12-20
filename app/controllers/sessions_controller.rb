class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
  end

  def create
    if user = User.authenticate_by(email_address: params[:email_address], password: params[:password])
      Rails.logger.info "User authenticated successfully: #{user.id}"

      session = user.sessions.create!(
        ip_address: request.ip,
        user_agent: request.user_agent
      )
      Rails.logger.info "Session created: #{session.id}"

      cookies.signed.permanent[:session_token] = { value: session.id, httponly: true }
      Rails.logger.info "About to redirect to: #{app_path}"

      redirect_to app_path and return
      Rails.logger.info "This line shouldn't be reached"
    else
      redirect_to new_session_path, alert: "Invalid email or password"
    end
  end

  def destroy
    Current.session&.destroy
    redirect_to root_path
  end
end
