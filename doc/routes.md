# Routes Documentation

## Public Routes

```ruby
# Root points to login
root "users/sessions#new"

# Devise authentication (Devise generates these)
devise_for :users, controllers: {
  registrations: "users/registrations",              # Custom registration with role selection
  sessions: "users/sessions"
}
```

---

## Client Routes

```ruby
namespace :client do
  root to: "dashboard#index"                         # Client dashboard with upcoming bookings and quick actions
  
  # Profile management
  resource :profile, only: [:show, :edit, :update]   # Client profile (display name, contact info, address)
  
  # Vehicle management
  resources :vehicles, except: [:show]               # CRUD for client vehicles (make, model, mileage)
  
  # Professional search and browsing
  resources :professionals, only: [:index, :show] do # Search/filter professionals and view their profiles
    member do
      get :availability                              # View professional's available time slots in calendar format
    end
  end
  
  # Bookings
  resources :bookings do
    member do
      patch :cancel                                  # Client cancels a booking
    end
    resources :messages, only: [:index, :create]     # Messages scoped to a specific booking
  end
  
  # Brick 2 - Payment & Reviews
  resources :payments, only: [:create, :show] do
    member do
      get :success                                   # Payment success callback page
      get :cancel                                    # Payment cancelled page
    end
  end
  
  resource :wallet, only: [:show]                    # Client wallet showing invoice history and payment records
  
  resources :invoices, only: [:index, :show] do
    member do
      get :download                                  # Download invoice PDF
    end
  end
  
  resources :reviews, only: [:new, :create]          # Leave reviews for professionals (associated with booking)
  
  resources :maintenance_reminders, only: [:index, :create, :update, :destroy]
end
```

---

## Professional Routes

```ruby
namespace :professional do
  root to: "dashboard#index"                         # Professional dashboard with pending bookings and statistics
  
  # Profile management
  resource :profile, only: [:show, :edit, :update] do
    member do
      get :preview                                   # Preview how profile appears to clients
    end
  end
  
  # Document uploads for verification
  resources :verification_documents, only: [:index, :create, :destroy]
  
  # Service offerings
  resources :professional_services, only: [:index, :create, :update, :destroy]
  
  # Availability calendar
  resources :availability_slots, except: [:show] do
    collection do
      get :calendar                                  # Calendar view of availability slots with weekly/monthly display
    end
  end
  
  # Bookings management
  resources :bookings, only: [:index, :show] do
    member do
      patch :confirm                                 # Accept a booking request
      patch :reject                                  # Reject a booking request
      patch :complete                                # Mark booking as completed (Brick 2)
      patch :update_price                            # Update final price after discussion (Brick 2)
    end
    resources :messages, only: [:index, :create]     # Messages scoped to a specific booking
  end
  
  # Brick 2 - Reviews & Invoices
  resources :reviews, only: [:index, :new, :create]  # View received reviews and leave reviews for clients
  resources :invoices, only: [:index, :show]         # View generated invoices for completed services
end
```

---

## Admin Routes

```ruby
namespace :admin do
  root to: "dashboard#index"                         # Admin dashboard with pending approvals and system overview
  
  # User management
  resources :users, only: [:index, :show, :edit, :update] do
    member do
      patch :suspend                                 # Suspend a user account
      patch :activate                                # Activate a suspended user account
    end
  end
  
  # Professional approval workflow
  resources :professional_approvals, only: [:index, :show] do
    member do
      patch :approve                                 # Approve professional registration
      patch :reject                                  # Reject professional registration with reason
    end
  end
  
  # Service catalog management
  resources :services                                # CRUD for predefined service catalog
  
  # Brick 2 - Review moderation
  resources :reviews, only: [:index, :show] do
    member do
      patch :approve                                 # Approve a review after moderation
      patch :reject                                  # Reject/hide a review with moderation notes
      patch :flag                                    # Flag a review for manual review
    end
  end
  
  # System monitoring (read-only)
  resources :bookings, only: [:index, :show]         # View all bookings for monitoring (no edit access)
  resources :payments, only: [:index, :show]         # View payment transactions for monitoring (Brick 2)
end
```

---

## Stripe Webhooks

```ruby
# Stripe webhooks (Brick 2) - outside namespace
post "webhooks/stripe", to: "webhooks#stripe"
```

---

## Route Helpers Summary

### Most Common Paths:
- `root_path` → Login page
- `client_root_path` → Client dashboard
- `professional_root_path` → Professional dashboard  
- `admin_root_path` → Admin dashboard
- `new_user_registration_path` → Sign up
- `new_user_session_path` → Sign in
- `destroy_user_session_path` → Sign out
- `client_professionals_path` → Browse professionals
- `client_professional_path(id)` → View professional profile
- `client_bookings_path` → Client's bookings list
- `professional_bookings_path` → Professional's bookings list
- `client_wallet_path` → Client's wallet/invoice history
- `admin_professional_approvals_path` → Pending professional approvals

---

## Route Constraints & Redirects

```ruby
# Authenticated root redirects based on user type
authenticated :user, ->(user) { user.is_a?(Admin) } do
  root to: "admin/dashboard#index", as: :admin_root
end

authenticated :user, ->(user) { user.is_a?(Professional) } do
  root to: "professional/dashboard#index", as: :professional_root
end

authenticated :user, ->(user) { user.is_a?(Client) } do
  root to: "client/dashboard#index", as: :client_root
end
```

---

## Notes

- Root path points directly to login (no landing page)
- All routes follow RESTful conventions
- Namespaces separate concerns by user role
- Messages are always scoped to bookings (no standalone messaging)
- Brick 2 routes are clearly marked with comments
- Custom member actions use PATCH for state changes
- No nested routes deeper than 2 levels (KISS principle)
- Download actions use GET (not POST) for browser compatibility
