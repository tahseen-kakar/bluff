class GameFormatsController < ApplicationController
  before_action :require_table
  before_action :set_game_format, only: [ :show, :edit, :update, :destroy ]

  def index
    @game_formats = Current.table.game_formats
  end

  def new
    @game_format = Current.table.game_formats.build
  end

  def create
    @game_format = Current.table.game_formats.build(game_format_params)

    if @game_format.save
      redirect_to app_game_formats_path, notice: "Game format was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @game_format.update(game_format_params)
      redirect_to app_game_formats_path, notice: "Game format was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game_format.destroy
    redirect_to app_game_formats_path, notice: "Game format was successfully deleted."
  end

  private

  def require_table
    redirect_to app_path, alert: "Please select a table first" unless Current.table
  end

  def set_game_format
    @game_format = Current.table.game_formats.find(params[:id])
  end

  def game_format_params
    params.require(:game_format).permit(:name, :description, :buy_in, denominations: [])
  end
end
