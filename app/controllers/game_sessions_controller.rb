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

  def select_format
    @game_formats = @table.game_formats
  end

  def select_players
    @game_session = @table.game_sessions.build(game_format_id: params[:game_format_id])
    @available_players = @table.players
  end

  def record_chips
    @game_session = @table.game_sessions.build(game_format_id: params[:game_format_id])
    @player_results = params[:player_ids].map do |player_id|
      @game_session.player_results.build(player_id: player_id)
    end
  end

  def create
    @game_session = @table.game_sessions.new

    if params[:player_ids].present?
      # Coming from select_players step
      @game_session.game_format_id = params[:game_format_id]

      # Build player results
      params[:player_ids].each do |player_id|
        @game_session.player_results.build(player_id: player_id)
      end

      if @game_session.save
        # Redirect to record chips with the same params
        redirect_to record_chips_table_game_sessions_path(
          @table,
          game_format_id: @game_session.game_format_id,
          player_ids: params[:player_ids]
        )
      else
        Rails.logger.error "Failed to save game session: #{@game_session.errors.full_messages.join(', ')}"
        @available_players = @table.players
        render :select_players, status: :unprocessable_entity
      end
    elsif params[:player_results].present?
      # Coming from record_chips step
      @game_session.recording_chips = true
      @game_session.assign_attributes(game_session_params)

      if @game_session.save
        redirect_to table_game_sessions_path(@table), notice: "Session was successfully created."
      else
        Rails.logger.error "Failed to save game session with chips: #{@game_session.errors.full_messages.join(', ')}"
        render :record_chips, status: :unprocessable_entity
      end
    end
  end

  private

  def set_table
    @table = Current.user.tables.find(params[:table_id])
  end

  def set_game_session
    @game_session = @table.game_sessions.find(params[:id])
  end

  def game_session_params
    params.permit(
      :game_format_id,
      player_ids: [],
      player_results_attributes: [ :player_id, :chip_counts ]
    )
  end
end
