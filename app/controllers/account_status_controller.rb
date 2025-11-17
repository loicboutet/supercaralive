class AccountStatusController < ApplicationController
  # Skip the status check to avoid infinite redirects
  skip_before_action :check_user_status
  
  # These pages should only be accessible to authenticated users with the corresponding status
  before_action :check_status_for_suspended, only: [:suspended]
  before_action :check_status_for_inactive, only: [:inactive]
  
  # GET /account_status/suspended
  def suspended
  end
  
  # GET /account_status/inactive
  def inactive
  end
  
  private
  
  def check_status_for_suspended
    unless user_signed_in? && current_user.suspended?
      redirect_to root_path
    end
  end
  
  def check_status_for_inactive
    unless user_signed_in? && current_user.inactive?
      redirect_to root_path
    end
  end
end

