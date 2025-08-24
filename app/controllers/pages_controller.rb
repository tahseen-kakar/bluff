class PagesController < ApplicationController
  allow_unauthenticated_access only: [ :home, :how_to ]

  def home
  end

  def how_to
  end
end
