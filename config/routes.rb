Rails.application.routes.draw do
  # Mockups routes (for development/design reference)
  get 'mockups', to: 'mockups#index'
  get 'mockups/index'
  get 'mockups/typography'
  get 'mockups/user_dashboard'
  get 'mockups/user_profile'
  get 'mockups/user_settings'
  get 'mockups/admin_dashboard'
  get 'mockups/admin_users'
  get 'mockups/admin_analytics'
  get 'mockups/professional_bookings', to: 'professional/bookings#index'
  get 'mockups/professional_invoices', to: 'professional/invoices#index'

  # Home/Landing page
  get 'home', to: 'home#index'
  
  # Public pages (accessible without authentication)
  get 'pages/cgu', to: 'pages#cgu'
  get 'pages/confidentiality', to: 'pages#confidentiality'
  
  # Account status pages (for blocked/inactive users)
  get 'account_status/suspended', to: 'account_status#suspended', as: :account_status_suspended
  get 'account_status/inactive', to: 'account_status#inactive', as: :account_status_inactive
  
  # PWA routes (accessible without authentication)
  get 'service-worker.js', to: 'pwa#service_worker', format: :js
  get 'manifest.json', to: 'pwa#manifest', format: :json
  
  # Root route (for logo links and general navigation)
  root to: 'home#index'

  # Devise authentication with custom controllers
  devise_for :users, controllers: {
    registrations: "users/registrations",
    sessions: "users/sessions",
    passwords: "users/passwords"
  }

  # Root route: redirect based on authentication status and role
  # Non-authenticated users are redirected to sign in by Devise's authenticate_user!
  # Authenticated users are redirected to their appropriate dashboard
  authenticated :user do
    root to: "home#index", as: :authenticated_root
  end
  
  # Non-authenticated users go to sign in
  unauthenticated :user do
    root to: redirect("/users/sign_in"), as: :unauthenticated_root
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
    resource :profile, only: [:show, :edit, :update], controller: 'profile' do
      get :preview
    end
    
    # Document uploads for verification
    resources :verification_documents, only: [:index, :create, :update, :destroy]
    
    # Service offerings
    resources :professional_services, except: [:show] do
      member do
        patch :toggle_active
      end
    end
    
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
    resources :users, only: [:index, :show, :new, :create, :edit, :update, :destroy] do
      member do
        patch :suspend
        patch :activate
        patch :deactivate
      end
    end
    
    # Professional approval workflow
    resources :professional_approvals, only: [:index, :show] do
      member do
        patch :approve
        patch :reject
        patch :update_notes
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

  # LetterOpenerWeb for email preview in development
  mount LetterOpenerWeb::Engine, at: "/letter_opener" if Rails.env.development?

end
