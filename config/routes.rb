Rails.application.routes.draw do
  devise_for :users
  
  root 'home#index'

  resources :users do
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
    member do
      get :new_proposition
      post :accept
      post :decline
      post :cancel
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
