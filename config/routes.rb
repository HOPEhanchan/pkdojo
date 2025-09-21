Rails.application.routes.draw do
  # Define your application routes per the DSL in https://guides.rubyonrails.org/routing.html

  # Devise の Sessions をアプリ側で上書き
  devise_for :users, controllers: { sessions: 'users/sessions' }

  # ゲストログイン（Users::SessionsController#guest_sign_in を叩く）
  devise_scope :user do
    post 'users/guest_sign_in', to: 'users/sessions#guest_sign_in', as: :guest_sign_in
  end

  # 一旦みんなこのroot
  root "games#index"

  ##ログイン済みの人のroot 一旦廃止
  #authenticated :user do
  #  root "games#index", as: :authenticated_root
  #end

  ##未ログインの人のroot（まずはゲームTOP。） 一旦廃止
  #unauthenticated do
  #  root "games#index"
  #end
  resources :games, only: [:index, :show] do
    post :shoot, on: :collection
    get  :stats, on: :collection  # /games/stats で戦績ページへ
  end

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check

  # Defines the root path route ("/")
  # root "posts#index"

end
