# Documentation: Access Restriction Logic for Non-Logged Users

## Overview

This document describes the comprehensive access restriction system implemented in the Hatmada Rails application. The system uses Devise for authentication combined with role-based access control to restrict access for non-logged users and provide role-specific functionality.

## Table of Contents

1. [Authentication Foundation](#authentication-foundation)
2. [Application-Wide Access Control](#application-wide-access-control)
3. [User Model and Roles](#user-model-and-roles)
4. [Controller-Level Access Control](#controller-level-access-control)
5. [Public Pages Configuration](#public-pages-configuration)
6. [Role-Based Dashboard Routing](#role-based-dashboard-routing)
7. [Implementation Guide](#implementation-guide)
8. [Code Examples](#code-examples)

## Authentication Foundation

### Devise Configuration

The application uses Devise with custom controllers for enhanced control:

```ruby
# config/routes.rb
devise_for :users, skip: [:registrations], controllers: {
  sessions: "users/sessions",
  passwords: "users/passwords"
}

devise_scope :user do
  # Custom registration routes by role
  get "/users/sign_up/manager", to: "users/registrations#new_manager"
  get "/users/sign_up/commercial", to: "users/registrations#new_commercial"
  post "/users/sign_up/manager", to: "users/registrations#create_manager"
  post "/users/sign_up/commercial", to: "users/registrations#create_commercial"
  
  # Redirect default sign up to sign in
  get "/users/sign_up", to: redirect("/users/sign_in")
end
```

### Custom Devise Controllers

```ruby
# app/controllers/users/sessions_controller.rb
class Users::SessionsController < Devise::SessionsController
  layout "authentication"
  
  # Skip authentication for logout action
  skip_before_action :authenticate_user!, only: [:destroy]
end

# app/controllers/users/registrations_controller.rb
class Users::RegistrationsController < Devise::RegistrationsController
  layout "application"
  
  # Allow unauthenticated access to registration pages
  skip_before_action :authenticate_user!, only: [:new_manager, :new_commercial, :create_manager, :create_commercial]
  
  # Role-specific registration methods
  def new_manager
    build_resource({})
    @user_type = "manager"
    render :new_manager
  end
  
  def new_commercial
    build_resource({})
    @user_type = "commercial"
    render :new_commercial
  end
  
  # Custom after_sign_up_path_for role-based redirection
  def after_sign_up_path_for(resource)
    if resource.manager?
      manager_dashboard_path
    elsif resource.commercial?
      root_path
    else
      root_path
    end
  end
end
```

## Application-Wide Access Control

### Global Authentication Requirement

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  # Require authentication for ALL pages by default
  before_action :authenticate_user!
  
  private
  
  # Admin access control
  def require_admin
    redirect_to root_path, alert: "Accès non autorisé." unless current_user&.has_admin_access?
  end
  
  # Manager or admin access control
  def require_manager_or_admin
    redirect_to root_path, alert: "Accès non autorisé." unless current_user&.has_admin_access?
  end
end
```

**Key Points:**
- `before_action :authenticate_user!` is applied globally
- All controllers inherit this restriction by default
- Public pages must explicitly skip this authentication
- Role-based methods provide additional access control layers

## User Model and Roles

### Role Definition and Methods

```ruby
# app/models/user.rb
class User < ApplicationRecord
  devise :database_authenticatable, :registerable,
         :recoverable, :rememberable, :validatable
  
  # User types definition
  USER_TYPES = %w[commercial manager admin].freeze
  
  # Validations
  validates :user_type, inclusion: { in: USER_TYPES }, allow_blank: true
  validates :email, presence: true, uniqueness: true
  
  # Scopes for easy querying
  scope :commercials, -> { where(user_type: "commercial") }
  scope :managers, -> { where(user_type: "manager") }
  scope :admins, -> { where(user_type: "admin") }
  
  # Role checking methods
  def commercial?
    user_type == "commercial"
  end
  
  def manager?
    user_type == "manager"
  end
  
  def admin?
    user_type == "admin"
  end
  
  # Access control method
  def has_admin_access?
    admin? || manager?
  end
end
```

## Controller-Level Access Control

### Role-Specific Controllers

Each user role has dedicated controllers with specific access restrictions:

#### Admin Controller
```ruby
# app/controllers/admin_controller.rb
class AdminController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  layout "admin"
  
  def dashboard
    # Admin-only functionality
  end
  
  private
  
  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès non autorisé."
    end
  end
end
```

#### Manager Controller
```ruby
# app/controllers/manager_controller.rb
class ManagerController < ApplicationController
  before_action :authenticate_user!
  before_action :require_manager
  layout "manager"
  
  def dashboard
    # Manager-only functionality
  end
  
  private
  
  def require_manager
    unless current_user&.manager?
      redirect_to root_path, alert: "Accès non autorisé."
    end
  end
end
```

#### Commercial Controller
```ruby
# app/controllers/commercial_controller.rb
class CommercialController < ApplicationController
  before_action :authenticate_user!
  before_action :require_commercial
  layout "commercial"
  
  def dashboard
    # Commercial-only functionality
  end
  
  private
  
  def require_commercial
    unless current_user&.commercial?
      redirect_to root_path, alert: "Accès non autorisé."
    end
  end
end
```

#### Mockups Controller (Admin-Only Access)
```ruby
# app/controllers/mockups_controller.rb
class MockupsController < ApplicationController
  before_action :authenticate_user!
  before_action :require_admin
  
  def index
    # Mockup pages accessible only to admins
  end
  
  private
  
  def require_admin
    unless current_user&.admin?
      redirect_to root_path, alert: "Accès non autorisé."
    end
  end
end
```

## Public Pages Configuration

### Allowing Unauthenticated Access

Certain controllers need to allow public access by skipping authentication:

#### Home Controller (Public Landing Pages)
```ruby
# app/controllers/home_controller.rb
class HomeController < ApplicationController
  layout "application"
  
  # Allow unauthenticated access to home pages
  skip_before_action :authenticate_user!
  
  def landing
    # Redirect logged-in users to their respective dashboards
    if user_signed_in? && current_user.admin?
      redirect_to admin_dashboard_path
    elsif user_signed_in? && current_user.manager?
      redirect_to manager_dashboard_path
    elsif user_signed_in? && current_user.commercial?
      redirect_to commercial_dashboard_path
    end
  end
  
  def legal
    # Public legal page
  end
  
  def cgu
    # Public terms page
  end
  
  def confidentiality
    # Public privacy page
  end
end
```

#### Pages Controller (Public Marketing Pages)
```ruby
# app/controllers/pages_controller.rb
class PagesController < ApplicationController
  layout "landing"
  
  # Allow unauthenticated access to public pages
  skip_before_action :authenticate_user!
  
  def landing
    # Public landing page
  end
  
  def typography_test
    # Public test page
    render layout: "application"
  end
end
```

## Role-Based Dashboard Routing

### Automatic Role-Based Redirection

The system automatically redirects users to appropriate dashboards based on their role:

```ruby
# In HomeController#landing
def landing
  # Redirect logged-in users to their respective dashboards
  if user_signed_in? && current_user.admin?
    redirect_to admin_dashboard_path
    nil
  elsif user_signed_in? && current_user.manager?
    redirect_to manager_dashboard_path
    nil
  elsif user_signed_in? && current_user.commercial?
    redirect_to commercial_dashboard_path
    nil
  end
end
```

### Route Organization

```ruby
# config/routes.rb
Rails.application.routes.draw do
  # Public routes (no authentication required)
  get "home/landing"
  get "home/legal"
  get "home/cgu"
  get "home/confidentiality"
  get "landing", to: "pages#landing"
  
  # Admin routes (admin access required)
  get "admin/dashboard", to: "admin#dashboard"
  
  # Manager routes (manager access required)
  get "manager/dashboard", to: "manager#dashboard"
  get "manager/missions", to: "manager#missions"
  # ... other manager routes
  
  # Commercial routes (commercial access required)
  get "commercial/dashboard", to: "commercial#dashboard"
  get "commercial/missions", to: "commercial#missions"
  # ... other commercial routes
  
  # Mockup routes (admin access required)
  get "mockups/index"
  get "mockups/freelancer_dashboard"
  # ... other mockup routes
  
  # Root route
  root "home#landing"
end
```

## Implementation Guide

### Step 1: Set Up Devise

```bash
# Add Devise to Gemfile
gem 'devise'

# Install Devise
rails generate devise:install
rails generate devise User
```

### Step 2: Configure Application Controller

```ruby
# app/controllers/application_controller.rb
class ApplicationController < ActionController::Base
  before_action :authenticate_user!
  
  private
  
  def require_admin
    redirect_to root_path, alert: "Accès non autorisé." unless current_user&.has_admin_access?
  end
  
  def require_manager_or_admin
    redirect_to root_path, alert: "Accès non autorisé." unless current_user&.has_admin_access?
  end
end
```

### Step 3: Add User Roles

```ruby
# Migration
class AddUserTypeToUsers < ActiveRecord::Migration[7.0]
  def change
    add_column :users, :user_type, :string
    add_index :users, :user_type
  end
end

# User model
class User < ApplicationRecord
  USER_TYPES = %w[commercial manager admin].freeze
  
  validates :user_type, inclusion: { in: USER_TYPES }, allow_blank: true
  
  def commercial?
    user_type == "commercial"
  end
  
  def manager?
    user_type == "manager"
  end
  
  def admin?
    user_type == "admin"
  end
  
  def has_admin_access?
    admin? || manager?
  end
end
```

### Step 4: Create Role-Specific Controllers

Create separate controllers for each role with appropriate access restrictions (see examples above).

### Step 5: Configure Public Pages

For any controller that should be accessible without authentication:

```ruby
class PublicController < ApplicationController
  skip_before_action :authenticate_user!
  
  def public_action
    # Public functionality
  end
end
```

### Step 6: Set Up Custom Devise Controllers

Create custom Devise controllers for enhanced control over authentication flow (see examples above).

## Code Examples

### Complete Access Control Pattern

```ruby
# Base pattern for protected controller
class ProtectedController < ApplicationController
  before_action :authenticate_user!           # Require login
  before_action :require_specific_role        # Require specific role
  layout "role_specific_layout"              # Use role-specific layout
  
  def action
    # Role-specific functionality
  end
  
  private
  
  def require_specific_role
    unless current_user&.specific_role?
      redirect_to root_path, alert: "Accès non autorisé."
    end
  end
end

# Base pattern for public controller
class PublicController < ApplicationController
  skip_before_action :authenticate_user!     # Allow public access
  layout "public_layout"                     # Use public layout
  
  def action
    # Public functionality
    
    # Optional: Redirect logged-in users
    if user_signed_in?
      redirect_to appropriate_dashboard_path
    end
  end
end
```

### Access Control Helper Methods

```ruby
# In ApplicationController or a concern
module AccessControl
  extend ActiveSupport::Concern
  
  private
  
  def require_admin
    redirect_to root_path, alert: "Accès non autorisé." unless current_user&.admin?
  end
  
  def require_manager
    redirect_to root_path, alert: "Accès non autorisé." unless current_user&.manager?
  end
  
  def require_commercial
    redirect_to root_path, alert: "Accès non autorisé." unless current_user&.commercial?
  end
  
  def require_manager_or_admin
    redirect_to root_path, alert: "Accès non autorisé." unless current_user&.has_admin_access?
  end
  
  def redirect_to_appropriate_dashboard
    return unless user_signed_in?
    
    if current_user.admin?
      redirect_to admin_dashboard_path
    elsif current_user.manager?
      redirect_to manager_dashboard_path
    elsif current_user.commercial?
      redirect_to commercial_dashboard_path
    end
  end
end
```

## Key Benefits

1. **Security by Default**: All pages require authentication unless explicitly made public
2. **Role-Based Access**: Clear separation of functionality by user role
3. **Centralized Control**: Access logic is centralized and reusable
4. **Flexible Public Pages**: Easy to create public marketing/legal pages
5. **Automatic Redirection**: Users are automatically directed to appropriate areas
6. **Maintainable**: Clear patterns make the system easy to extend and maintain

## Security Considerations

1. **Default Deny**: The system denies access by default, requiring explicit permission
2. **Role Validation**: All role checks include nil safety (`current_user&.role?`)
3. **Consistent Patterns**: All controllers follow the same access control patterns
4. **Clear Error Messages**: Users receive clear feedback when access is denied
5. **Secure Redirects**: Failed access attempts redirect to safe locations

This documentation provides a complete blueprint for implementing similar access restriction logic in other Rails applications.
