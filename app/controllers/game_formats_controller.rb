class GameFormatsController < ApplicationController
  before_action :require_table
  before_action :set_game_format, only: [ :edit, :update, :destroy ]

  def index
    @table = Current.table
    @game_formats = @table.game_formats
  end

  def new
    @table = Current.table
    @game_format = @table.game_formats.build
  end

  def create
    @table = Current.table
    @game_format = @table.game_formats.build(game_format_params)

    if @game_format.save
      redirect_to table_game_formats_path(@table), notice: "Game format was successfully created."
    else
      Rails.logger.warn "Game format validation failed: #{@game_format.errors.full_messages}"
      render :new, status: :unprocessable_entity
    end
  end

  def edit
    @table = Current.table
  end

  def update
    @table = Current.table
    if @game_format.update(game_format_params)
      redirect_to table_game_formats_path(@table), notice: "Game format was successfully updated."
    else
      Rails.logger.warn "Game format validation failed: #{@game_format.errors.full_messages}"
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @table = Current.table
    @game_format.destroy
    redirect_to table_game_formats_path(@table), notice: "Game format was successfully deleted."
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

  def set_game_format
    @game_format = Current.table.game_formats.find(params[:id])
  end

  def game_format_params
    # Convert the flat array of alternating color/value pairs into an array of hashes
    raw_params = params.require(:game_format).permit(:name, :description, :buy_in, denominations: [])

    # Process denominations to pair color and value
    if raw_params[:denominations].present?
      colors = raw_params[:denominations].values_at(* raw_params[:denominations].each_index.select(&:even?))
      values = raw_params[:denominations].values_at(* raw_params[:denominations].each_index.select(&:odd?))
      raw_params[:denominations] = colors.zip(values).map { |color, value| { "color" => color, "value" => value } }
    end

    raw_params
  end
end
