Rails.application.routes.draw do
  root "pages#home"

  # Authentication routes for Rails 8
  get  "sign_in", to: "sessions#new"
  post "sign_in", to: "sessions#create"
  get  "sign_up", to: "registrations#new"
  post "sign_up", to: "registrations#create"
  delete "sign_out", to: "sessions#destroy"

  # Password reset
  resource :password, param: :token

  # Main app routes
  get "app", to: "dashboard#show"

  # Table routes with cleaner URLs
  post "app/:id/switch", to: "tables#switch", as: :switch_table
  resources :tables, path: "app", only: [ :new, :create, :edit, :update, :destroy ]

  # Scoped routes under the current table
  scope "app/:table_id", as: "table" do
    resources :game_formats
    resources :players
    resources :sessions, as: :game_sessions # Renamed to avoid conflict with auth sessions
  end
end
