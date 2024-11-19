Rails.application.routes.draw do
  devise_for :users
  root to: 'user_cards#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :matches, only: [:index, :show] do
    collection do
      # Si tu veux ajouter des routes spéciales comme :
      get 'by_user/:user_id', to: 'matches#by_user', as: :by_user
    end
  end
  resources :trades do
    member do
      patch :accept
      patch :reject
      patch :complete
    end
    
    resources :trade_user_cards, only: [:create, :destroy], as: :cards
  end
  resources :users, only: [:show, :edit, :update] do
    resources :matches, only: [:index]
    resources :trades, only: [:index]
    resources :user_cards, only: [:index, :destroy, :new, :edit, :create, :update]
    resources :user_wanted_cards, only: [:index, :destroy, :new, :edit, :create, :update]
    resources :chatrooms, only: [:index, :show, :new, :create, :update, :destroy] do
      resources :messages, only: [:create]
    end
  end
  get 'dashboard/matches', to: 'dashboard#matches'
  get 'cards/search', to: 'cards#search', defaults: { format: 'json' }
  get 'cards/versions', to: 'cards#versions', defaults: { format: 'json' }
end


