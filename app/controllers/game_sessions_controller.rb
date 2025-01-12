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
    @game_session.recording_chips = true

    # Calculate total chips from player results
    total_chips = 0

    # Get permitted parameters for player results
    permitted_results = params.require(:player_results).permit!.to_h

    # Build player results with chip counts
    if permitted_results.present?
      permitted_results.each do |player_id, data|
        next if data[:chip_counts].values.all?(&:blank?) # Skip if all chip counts are blank

        chip_counts = data[:chip_counts].reject { |_, v| v.blank? }

        # Calculate player total
        player_total = calculate_player_total(chip_counts, @game_session.game_format)
        total_chips += player_total

        @game_session.player_results.build(
          player_id: player_id,
          chip_counts: chip_counts,
          total_amount: player_total
        )
      end
    end

    @game_session.total_chips = total_chips

    if @game_session.save
      redirect_to table_game_sessions_path(@table), notice: "Session was successfully created."
    else
      Rails.logger.error "Failed to save game session: #{@game_session.errors.full_messages}"
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

  def game_session_params
    params.permit(
      :game_format_id,
      player_ids: [],
      player_results: {}
    )
  end

  def calculate_player_total(chip_counts, game_format)
    chip_counts.sum do |color, count|
      denomination = game_format.denominations.find { |d| d["color"] == color }
      next 0 unless denomination

      count.to_i * denomination["value"].to_f
    end
  end
end
