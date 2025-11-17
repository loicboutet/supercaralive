class Admin::DashboardController < ApplicationController
  layout 'admin'
  before_action :require_admin

  # GET /admin
  def index
    # Renders view with dummy data
  end
end
