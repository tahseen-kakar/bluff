class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_request_details

  private

  def set_current_request_details
    Current.user = User.find_by(id: session[:user_id]) if session[:user_id]

    if session[:current_table_id] && Current.user
      Current.table = Current.user.tables.find_by(id: session[:current_table_id])
    end
  end
end
