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

class GameSessionsController < ApplicationController
  before_action :set_table

  def index
    @game_sessions = @table.game_sessions.includes(:game_format, player_results: :player)
                          .order(created_at: :desc)
  end

  def select_format
    @game_formats = @table.game_formats
  end

  def select_players
    @game_session = @table.game_sessions.build(game_format_id: params[:game_format_id])
    @available_players = @table.players
  end

  def record_chips
    @game_session = @table.game_sessions.find(params[:id])
    @player_results = @game_session.player_results.includes(:player)
  end

  private

  def set_table
    @table = Current.session.user.tables.find(params[:table_id])
  end
end
