Rails.application.routes.draw do
  get "game_formats/index"
  get "game_formats/new"
  get "game_formats/create"
  get "game_formats/edit"
  get "game_formats/update"
  get "game_formats/destroy"
  # Set the root path to our new home page
  root "pages#home"

  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check

  get "app", to: "dashboard#show"

  resources :tables do
    resources :game_formats
  end
end
