class DashboardController < ApplicationController
  def show
    Rails.logger.info "Dashboard#show accessed"  # Add logging
  end
end
