Rails.application.routes.draw do
  root "dashboard#dashboard"

  resources :tables do
    resources :players
    resources :game_formats
    resources :game_sessions, only: [ :index, :show, :new, :create ]
  end
end
