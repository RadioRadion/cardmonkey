Rails.application.routes.draw do
  devise_for :users
  root to: 'cards#index'
  # For details on the DSL available within this file, see https://guides.rubyonrails.org/routing.html

  resources :users, only: [:show, :edit, :update] do
    resources :user_cards, only: [:index, :destroy, :new, :edit, :create, :update]
    resources :user_wanted_cards, only: [:index, :destroy, :new, :edit, :create, :update]
    resources :trades, only: [:index, :create, :show, :edit, :update]
    resources :chatrooms, only: [:index, :show, :new, :create, :update, :destroy] do
      resources :messages, only: [:create]
    end
  end
end


