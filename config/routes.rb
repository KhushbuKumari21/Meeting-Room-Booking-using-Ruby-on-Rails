Rails.application.routes.draw do
  root "home#index"
  devise_for :users, controllers: {
    passwords: 'devise/passwords'
  }

  authenticated :user do
    root to: 'dashboard#index', as: :authenticated_root
  end

  devise_scope :user do
    get 'users/sign_out', to: 'devise/sessions#destroy'
  end

  resources :meeting_rooms, only: [:index, :show]

  resources :bookings, only: [:index, :new, :create, :show, :destroy] do
    member do
      patch :cancel_booking
    end
  end

  namespace :admin do
    root to: 'dashboard#index'  
    get 'dashboard', to: 'dashboard#index', as: :admin_dashboard
    
    resources :meeting_rooms  
    resources :bookings, only: [:index]
  end
end
