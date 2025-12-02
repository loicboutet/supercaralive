class Users::PasswordsController < Devise::PasswordsController
  # Allow unauthenticated access to password recovery pages
  skip_before_action :authenticate_user!
  
  # GET /users/password/new
  def new
    super
  end

  # POST /users/password
  def create
    super
  end

  # GET /users/password/edit?reset_password_token=xxx
  def edit
    super
  end

  # PUT /users/password
  def update
    super
  end
end





