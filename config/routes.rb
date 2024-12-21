Rails.application.routes.draw do
  root "pages#home"

  resource :session
  resources :passwords, param: :token

  get "app", to: "dashboard#show"

  # Table routes with cleaner URLs
  post "app/:id/switch", to: "tables#switch", as: :switch_table
  resources :tables, path: "app", only: [ :new, :create, :edit, :update, :destroy ]

  # Scoped routes under the current table
  scope "app/:table_id", as: "table" do
    resources :game_formats
    resources :players
    resources :sessions
  end
end
