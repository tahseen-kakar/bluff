Rails.application.routes.draw do
  # Set the root path to our new home page
  root "pages#home"

  resource :session
  resources :passwords, param: :token

  get "up" => "rails/health#show", as: :rails_health_check
end
