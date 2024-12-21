class TablesController < ApplicationController
  before_action :authenticate
  before_action :set_table, only: [ :show, :edit, :update, :destroy, :switch ]

  def index
    @tables = Current.user.tables.order(created_at: :desc)
  end

  def show
  end

  def new
    @table = Current.user.tables.build
  end

  def create
    @table = Current.user.tables.build(table_params)

    if @table.save
      redirect_to app_path, notice: "Table was successfully created."
    else
      render :new, status: :unprocessable_entity
    end
  end

  def edit
  end

  def update
    if @table.update(table_params)
      redirect_to @table, notice: "Table was successfully updated."
    else
      render :edit, status: :unprocessable_entity
    end
  end

  def destroy
    @table.destroy
    redirect_to app_path, notice: "Table was successfully deleted."
  end

  def switch
    session[:current_table_id] = @table.id
    Current.table = @table
    redirect_to app_path, notice: "Switched to #{@table.name}"
  rescue ActiveRecord::RecordNotFound
    redirect_to app_path, alert: "Table not found"
  end

  private

  def authenticate
    redirect_to sign_in_path unless Current.user
  end

  def set_table
    @table = Current.user.tables.find(params[:id])
  end

  def table_params
    params.require(:table).permit(:name, :description)
  end
end
