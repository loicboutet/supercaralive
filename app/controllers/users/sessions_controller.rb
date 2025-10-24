class Users::SessionsController < Devise::SessionsController
  # GET /users/sign_in
  def new
    super
  end

  # POST /users/sign_in
  def create
    super
  end

  # DELETE /users/sign_out
  def destroy
    super
  end

  protected

  # The path used after sign in.
  def after_sign_in_path_for(resource)
    client_root_path
  end

  # The path used after sign out.
  def after_sign_out_path_for(resource_or_scope)
    new_user_session_path
  end
end
