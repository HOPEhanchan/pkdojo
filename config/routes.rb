Rails.application.routes.draw do
  devise_for :users, controllers: { sessions: 'users/sessions' } # Devise の Sessions をアプリ側で上書き

# ゲストログイン（Users::SessionsController#guest_sign_in を叩く）
  devise_scope :user do
    post 'users/guest_sign_in', to: 'users/sessions#guest_sign_in', as: :guest_sign_in
  end

  resources :games, only: [:index, :show] do
    post :shoot, on: :collection
    get  :stats, on: :collection  # /games/stats で戦績ページへ
  end

  root "games#index" # 一旦みんなこのroot

  # Reveal health status on /up that returns 200 if the app boots with no exceptions, otherwise 500.
  # Can be used by load balancers and uptime monitors to verify that the app is live.
  get "up" => "rails/health#show", as: :rails_health_check
end
