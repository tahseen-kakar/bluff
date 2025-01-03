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

class DashboardController < ApplicationController
  before_action :authenticate

  def show
    if Current.user.tables.none?
      render "no_tables"
    elsif !session[:current_table_id]
      @tables = Current.user.tables.order(created_at: :desc)
      render "select_table"
    else
      @table = Current.user.tables.find(session[:current_table_id])
      render "dashboard"
    end
  end

  private

  def authenticate
    redirect_to sign_in_path unless Current.user
  end
end
