Rails.application.routes.draw do
  # Mockups routes (for development/design reference)
  get 'mockups/index'
  get 'mockups/typography'
  get 'mockups/user_dashboard'
  get 'mockups/user_profile'
  get 'mockups/user_settings'
  get 'mockups/admin_dashboard'
  get 'mockups/admin_users'
  get 'mockups/admin_analytics'

  # Home/Landing page
  get 'home', to: 'home#index'

  # Devise authentication with custom controllers
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions"
  }

  # Authenticated users go to client dashboard by default
  authenticated :user do
    root to: "client/dashboard#index", as: :authenticated_root
  end

  # Client Routes
  namespace :client do
    root to: "dashboard#index"
    
    # Profile management
    resource :profile, only: [:show, :edit, :update]
    
    # Vehicle management
    resources :vehicles, except: [:show]
    
    # Professional search and browsing
    resources :professionals, only: [:index, :show] do
      member do
        get :availability
      end
    end
    
    # Bookings
    resources :bookings do
      member do
        patch :cancel
      end
      resources :messages, only: [:index, :create]
    end
    
    # Brick 2 - Payment & Reviews
    resources :payments, only: [:create, :show] do
      member do
        get :success
        get :cancel
      end
    end
    
    resource :wallet, only: [:show]
    
    resources :invoices, only: [:index, :show] do
      member do
        get :download
      end
    end
    
    resources :reviews, only: [:new, :create]
    
    resources :maintenance_reminders, only: [:index, :create, :update, :destroy]
  end

  # Professional Routes
  namespace :professional do
    root to: "dashboard#index"
    
    # Profile management
    resource :profile, only: [:show, :edit, :update] do
      member do
        get :preview
      end
    end
    
    # Document uploads for verification
    resources :verification_documents, only: [:index, :create, :destroy]
    
    # Service offerings
    resources :professional_services, only: [:index, :create, :update, :destroy]
    
    # Availability calendar
    resources :availability_slots, except: [:show] do
      collection do
        get :calendar
      end
    end
    
    # Bookings management
    resources :bookings, only: [:index, :show] do
      member do
        patch :confirm
        patch :reject
        patch :complete
        patch :update_price
      end
      resources :messages, only: [:index, :create]
    end
    
    # Brick 2 - Reviews & Invoices
    resources :reviews, only: [:index, :new, :create]
    resources :invoices, only: [:index, :show]
  end

  # Admin Routes
  namespace :admin do
    root to: "dashboard#index"
    
    # User management
    resources :users, only: [:index, :show, :edit, :update] do
      member do
        patch :suspend
        patch :activate
      end
    end
    
    # Professional approval workflow
    resources :professional_approvals, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
      end
    end
    
    # Service catalog management
    resources :services
    
    # Brick 2 - Review moderation
    resources :reviews, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
        patch :flag
      end
    end
    
    # System monitoring (read-only)
    resources :bookings, only: [:index, :show]
    resources :payments, only: [:index, :show]
  end

  # Stripe webhooks (Brick 2)
  post "webhooks/stripe", to: "webhooks#stripe"

  # Health check
  get "up" => "rails/health#show", as: :rails_health_check

  # Root points to mockups index
  root "mockups#index"
end
