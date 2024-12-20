class SessionsController < ApplicationController
  allow_unauthenticated_access only: %i[ new create ]

  def new
  end

  def create
    if user = User.authenticate_by(email_address: params[:email_address], password: params[:password])
      session = user.sessions.create!(
        ip_address: request.ip,
        user_agent: request.user_agent
      )

      cookies.signed.permanent[:session_token] = { value: session.id, httponly: true }

      redirect_to app_path
    else
      redirect_to new_session_path, alert: "Invalid email or password"
    end
  end

  def destroy
    Current.session&.destroy
    redirect_to root_path
  end
end
