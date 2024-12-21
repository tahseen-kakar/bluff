class DashboardController < ApplicationController
  before_action :authenticate

  def show
    if Current.user.tables.none?
      render "no_tables"
    elsif !session[:current_table_id]
      @tables = Current.user.tables.order(created_at: :desc)
      render "select_table"
    else
      @table = Current.user.tables.find(session[:current_table_id])
      render "dashboard"
    end
  end

  private

  def authenticate
    redirect_to sign_in_path unless Current.user
  end
end
