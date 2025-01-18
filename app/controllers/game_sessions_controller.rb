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
    Rails.logger.info "Creating new game session with params: #{params.inspect}"

    @game_session = @table.game_sessions.new(game_format_id: params[:game_format_id])
    @game_session.recording_chips = true

    Rails.logger.info "Created game session with format: #{@game_session.game_format.inspect}"

    # Calculate total chips from player results
    total_chips = 0

    # Get permitted parameters for player results
    permitted_results = params.require(:player_results).permit!.to_h
    Rails.logger.info "Permitted player results: #{permitted_results.inspect}"

    # Track selected players for validation
    selected_players = []

    # Build player results with chip counts
    if permitted_results.present?
      permitted_results.each do |player_id, data|
        Rails.logger.info "Processing player #{player_id} with data: #{data.inspect}"

        # Skip if player wasn't selected (no chip counts data)
        next unless data[:chip_counts].present?

        selected_players << player_id

        # Convert blank values to "0"
        chip_counts = data[:chip_counts].transform_values { |v| v.presence || "0" }
        Rails.logger.info "Normalized chip counts: #{chip_counts.inspect}"

        # Calculate player total
        cash_out_amount = calculate_player_total(chip_counts, @game_session.game_format)
        total_chips += cash_out_amount

        Rails.logger.info "Player cash out: $#{cash_out_amount}, Running total: $#{total_chips}"

        # Get player and calculate loan needed
        player = @table.players.find(player_id)
        buy_in_amount = @game_session.game_format.buy_in
        loan_taken = player.loan_needed_for_game(buy_in_amount)

        result = @game_session.player_results.build(
          player_id: player_id,
          chip_counts: chip_counts,
          cash_out_amount: cash_out_amount,
          buy_in_amount: buy_in_amount,
          loan_taken: loan_taken
        )
        Rails.logger.info "Built player result: #{result.inspect}"

        # We don't need to update the player's loan here as it's handled by PlayerResult's after_save callback
        player.with_lock do
          if loan_taken > 0
            # When taking a loan, just set wallet balance to 0 since loan handling is in PlayerResult
            player.wallet_balance = 0
          else
            # No loan needed, deduct buy_in and add cash_out
            new_balance = player.wallet_balance - buy_in_amount + cash_out_amount
            raise ArgumentError, "Insufficient wallet balance" if new_balance < 0
            player.wallet_balance = new_balance
          end
          player.save!
        end
      end
    end

    @game_session.total_chips = total_chips
    Rails.logger.info "Final game session total: $#{total_chips}"

    if selected_players.any? && @game_session.save
      Rails.logger.info "Successfully saved game session #{@game_session.id}"
      Rails.logger.info "Player results saved: #{@game_session.player_results.map { |pr| { player_id: pr.player_id, cash_out: pr.cash_out_amount, loan: pr.loan_taken, chips: pr.chip_counts } }.inspect}"
      redirect_to table_game_sessions_path(@table), notice: "Session was successfully created."
    else
      Rails.logger.error "Failed to save game session: #{@game_session.errors.full_messages}"
      Rails.logger.error "Validation errors: #{@game_session.errors.details.inspect}"
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
    Rails.logger.info "Calculating total for chip counts: #{chip_counts.inspect}"
    Rails.logger.info "Using game format: #{game_format.inspect}"

    total = chip_counts.sum do |color, count|
      denomination = game_format.denominations.find { |d| d["color"] == color }
      Rails.logger.info "Found denomination for #{color}: #{denomination.inspect}"

      next 0 unless denomination
      value = count.to_i * denomination["value"].to_f
      Rails.logger.info "Calculated value for #{color}: #{count} × #{denomination["value"]} = #{value}"
      value
    end

    Rails.logger.info "Total calculated: #{total}"
    total
  end
end
