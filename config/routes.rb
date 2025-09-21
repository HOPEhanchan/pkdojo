Rails.application.routes.draw do

  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html
  devise_for :users
  #ログイン済みの人のroot
  authenticated :user do
    root "games#index", as: :authenticated_root
  end

  #未ログインの人のroot（まずはゲームTOP。）
  unauthenticated do
    root "games#index"
  end

  resources :games, only: [:index, :show] do
    post :shoot, on: :collection
    collection { get :stats } # /games/stats で戦績ページへ
  end

  root "games#index"
  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"
end
