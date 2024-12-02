Rails.application.routes.draw do
  devise_for :users
  
  root 'home#index'

  # Direct messaging route
  get 'messages', to: redirect { |p, req| "/users/#{req.env['warden'].user.id}/chatrooms" }, as: :messages
  
  resources :users do
    collection do
      get :search
    end
    member do
      get :profile
      get :dashboard
    end
    resources :chatrooms do
      resources :messages do
        member do
          post :toggle_reaction
          post :mark_delivered
        end
      end
    end
    resources :user_cards
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
  end

  resources :matches do
    collection do
      get :dashboard
    end
  end

  resources :cards, only: [:index, :show] do
    collection do
      get :search
      get :autocomplete
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

  # API endpoints for real-time features
  post 'messages/:id/mark_read', to: 'messages#mark_read'
  
  # Websocket mounting
  mount ActionCable.server => '/cable'
end
