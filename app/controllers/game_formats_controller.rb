class GameFormatsController < ApplicationController
  before_action :set_table
  before_action :set_game_format, only: [ :show, :edit, :update, :destroy ]

  def index
    @game_formats = @table.game_formats
  end

  def show
  end

  def new
    @game_format = @table.game_formats.build
  end

  def create
    @game_format = @table.game_formats.build(game_format_params)

    if @game_format.save
      redirect_to table_game_formats_path(@table), notice: "Game format was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @game_format.update(game_format_params)
      redirect_to table_game_formats_path(@table), notice: "Game format was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @game_format.destroy
    redirect_to table_game_formats_path(@table), notice: "Game format was successfully deleted."
  end

  private

  def set_table
    @table = Current.user.tables.find(params[:table_id])
  end

  def set_game_format
    @game_format = @table.game_formats.find(params[:id])
  end

  def game_format_params
    params.require(:game_format).permit(:name, :description, :buy_in, denominations: [])
  end
end
