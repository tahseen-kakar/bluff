Rails.application.routes.draw do
  root "pages#home"

  resource :session
  resources :passwords, param: :token

  get "app", to: "dashboard#show"
  scope "app" do
    resources :tables do
      post :switch, on: :member
      resources :game_formats
      resources :players
      resources :sessions
    end
  end
end
