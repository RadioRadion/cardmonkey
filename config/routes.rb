Rails.application.routes.draw do
  devise_for :users
  root to: 'user_cards#index'

  # Routes pour matches
  resources :matches, only: [:index, :show] do
    collection do
      get 'by_user/:user_id', to: 'matches#by_user', as: :by_user
    end
  end

  # Routes pour trades unifiées
  resources :trades do
    member do
      patch :accept
      patch :reject
      patch :complete
    end

    collection do
      get :new_proposition
      get :update_trade_value
      get :search_cards
    end

    resources :trade_user_cards, only: [:create, :destroy], as: :cards
  end

  # Routes imbriquées dans users
  resources :users, only: [:show, :edit, :update] do
    resources :matches, only: [:index]
    resources :trades, only: [:index]
    resources :user_cards, only: [:index, :destroy, :new, :edit, :create, :update]
    resources :user_wanted_cards, only: [:index, :destroy, :new, :edit, :create, :update]
    resources :chatrooms, only: [:index, :show, :new, :create, :update, :destroy] do
      resources :messages, only: [:create]
    end
  end

  # Routes additionnelles
  get 'dashboard/matches', to: 'dashboard#matches'
  get 'cards/search', to: 'cards#search', defaults: { format: 'json' }
  get 'cards/versions', to: 'cards#versions', defaults: { format: 'json' }
end
