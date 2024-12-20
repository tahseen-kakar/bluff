class DashboardController < ApplicationController
  # Comment this out temporarily for testing
  # before_action :require_authentication

  def show
    Rails.logger.info "Dashboard#show accessed"  # Add logging
  end
end
