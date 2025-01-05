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
  before_action :set_game_session, only: [ :show ]

  def index
    @game_sessions = @table.game_sessions.order(created_at: :desc)
  end

  def show
    @player_results = @game_session.player_results.includes(:player)
  end

  def new
    @game_session = @table.game_sessions.build
    @game_formats = @table.game_formats
    @available_players = @table.players

    # Pass game formats data to JavaScript
    @game_formats_json = @game_formats.map { |format|
      {
        id: format.id,
        name: format.name,
        buy_in: format.buy_in,
        denominations: format.denominations
      }
    }.to_json
  end

  def create
    @game_session = @table.game_sessions.new(game_format_id: params[:game_format_id])

    # Build player results with chip counts
    params[:player_results]&.each do |player_id, data|
      @game_session.player_results.build(
        player_id: player_id,
        chip_counts: data[:chip_counts]
      )
    end

    if @game_session.save
      redirect_to table_game_sessions_path(@table), notice: "Session was successfully created."
    else
      @game_formats = @table.game_formats
      @available_players = @table.players
      @game_formats_json = @game_formats.map { |format|
        {
          id: format.id,
          name: format.name,
          buy_in: format.buy_in,
          denominations: format.denominations
        }
      }.to_json
      render :new, status: :unprocessable_entity
    end
  end

  private

  def set_table
    @table = Current.user.tables.find(params[:table_id])
  end

  def set_game_session
    @game_session = @table.game_sessions.find(params[:id])
  end
end
