class SettingsController < ApplicationController
  def show
  end

  def update_password
    if Current.user.update(password_params)
      redirect_to settings_path, notice: "Password has been updated successfully."
    else
      render :show, status: :unprocessable_entity
    end
  end

  private

  def password_params
    params.require(:user).permit(:password, :password_confirmation)
  end
end
