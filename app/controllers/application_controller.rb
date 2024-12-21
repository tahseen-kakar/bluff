class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_request_details

  private

  def set_current_request_details
    # Current.user is already set by Authentication concern
    if session[:current_table_id] && Current.session&.user
      Current.table = Current.session.user.tables.find_by(id: session[:current_table_id])
    end
  end
end
