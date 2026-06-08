Rails.application.routes.draw do
  devise_for :users
  
  root 'home#index'

  # Direct messaging route
  get 'messages', to: redirect { |p, req| "/users/#{req.env['warden'].user.id}/chatrooms" }, as: :messages
  
  resources :users do
    collection do
      get :search
    end
    resources :chatrooms do
      resources :messages do
        member do
          post :toggle_reaction
          post :mark_delivered
        end
      end
    end
    resources :user_cards do
      collection do
        get :import
        post :import_run
      end
    end
    resources :user_wanted_cards
  end

  resources :trades do
    collection do
      get :search_cards
    end
    member do
      get :new_proposition
      post :accept
      post :decline
      post :cancel
      patch :validate
    end
    resources :ratings, only: [:new, :create]
  end

  resources :matches, only: [:index, :show]

  resources :cards, only: [:index, :show] do
    collection do
      get :search
      get :versions
    end
  end

  resources :notifications, only: [:index] do
    collection do
      post :mark_all_as_read
    end
    member do
      post :mark_as_read
    end
  end

  # Static pages
  get 'privacy-policy', to: 'pages#privacy_policy', as: :privacy_policy

  # Websocket mounting
  mount ActionCable.server => '/cable'
end
