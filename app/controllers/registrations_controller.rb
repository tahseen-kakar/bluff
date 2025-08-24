class RegistrationsController < ApplicationController
  allow_unauthenticated_access

  def new
    @user = User.new
  end

  def create
    @user = User.new(user_params)

    if @user.save
      session = @user.sessions.create!(
        ip_address: request.ip,
        user_agent: request.user_agent
      )

      set_current_session(session)
      cookies.signed[:session_token] = {
        value: session.id,
        httponly: true,
        expires: 2.weeks.from_now,
        secure: !Rails.env.development?
      }
      
      redirect_to app_path, notice: "Welcome! Your account has been created successfully."
    else
      render :new, status: :unprocessable_entity
    end
  end

  private

  def user_params
    params.require(:user).permit(:name, :username, :email_address, :password, :password_confirmation)
  end
end
