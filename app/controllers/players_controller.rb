class PlayersController < ApplicationController
  before_action :require_table
  before_action :set_player, only: [ :edit, :update, :destroy ]

  def index
    @table = Current.table
    @players = @table.players
  end

  def new
    @table = Current.table
    @player = @table.players.build
  end

  def create
    @table = Current.table
    @player = @table.players.build(player_params)

    if @player.save
      redirect_to table_players_path(@table), notice: "Player was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @table = Current.table
  end

  def update
    @table = Current.table
    if @player.update(player_params)
      redirect_to table_players_path(@table), notice: "Player was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @table = Current.table
    @player.destroy
    redirect_to table_players_path(@table), notice: "Player was successfully deleted."
  end

  private

  def require_table
    unless Current.table
      Rails.logger.warn "No table selected. Session table_id: #{session[:current_table_id]}"
      redirect_to app_path, alert: "Please select a table first"
      return
    end

    # Double check that the table belongs to the current user
    unless Current.session&.user&.tables&.exists?(Current.table.id)
      Rails.logger.warn "Table #{Current.table.id} does not belong to user #{Current.session&.user&.id}"
      session.delete(:current_table_id)
      redirect_to app_path, alert: "Invalid table selected"
    end
  end

  def set_player
    @player = Current.table.players.find(params[:id])
  end

  def player_params
    params.require(:player).permit(:name, :email, :notes)
  end
end
