# This file is part of Bluff.
#
# Bluff is free software: you can redistribute it and/or modify it under the
# terms of the GNU General Public License as published by the Free Software
# Foundation, either version 3 of the License, or (at your option) any later version.
#
# Bluff is distributed in the hope that it will be useful, but WITHOUT ANY WARRANTY;
# without even the implied warranty of MERCHANTABILITY or FITNESS FOR A PARTICULAR
# PURPOSE. See the GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License along with Bluff.
# If not, see <https://www.gnu.org/licenses/>.

class ApplicationController < ActionController::Base
  include Authentication
  # Only allow modern browsers supporting webp images, web push, badges, import maps, CSS nesting, and CSS :has.
  allow_browser versions: :modern

  before_action :set_current_request_details

  private

  def set_current_request_details
    # Current.user is already set by Authentication concern
    if session[:current_table_id] && Current.session&.user
      Rails.logger.info "Setting current table from session: #{session[:current_table_id]}"
      Current.table = Current.session.user.tables.find_by(id: session[:current_table_id])
      if Current.table
        Rails.logger.info "Current table set to: #{Current.table.name}"
      else
        Rails.logger.warn "Could not find table with id: #{session[:current_table_id]}"
        session.delete(:current_table_id) # Clean up invalid table id
      end
    end
  end
end
